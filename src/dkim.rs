use std::borrow::Cow;

use base64::prelude::*;
use mail_auth::{
    common::{headers::Writable, verify::VerifySignature},
    dkim::verify::Verifier,
    AuthenticatedMessage, DkimResult, MessageAuthenticator,
};
use regex::bytes::Regex;
use rsa::{pkcs8::DecodePublicKey, traits::PublicKeyParts, BigUint, RsaPublicKey};

const TEST_MESSAGE: &str = r#"Delivered-To: bartosz@herodotus.dev
Received: by 2002:a17:906:710f:b0:ab6:41ea:5783 with SMTP id x15csp397821ejj;
        Thu, 30 Jan 2025 11:13:40 -0800 (PST)
X-Received: by 2002:a2e:a588:0:b0:302:350c:c630 with SMTP id 38308e7fff4ca-30796857bb4mr33985241fa.22.1738264420723;
        Thu, 30 Jan 2025 11:13:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1738264420; cv=none;
        d=google.com; s=arc-20240605;
        b=IWrv4AFqHrFnlFMPPZh7UOOY1fGSij2Yp1rno00PXjX7/3PLSNVJ4X0/7OZVylsHfY
         N0QMqAjbYCuMS59bHL6OO8T/lwgkZCJ/pTFi4PQqBY/xf+2izkpxvNEljKjdksFwcX8h
         IAZrhPQEkSe/A3Q3VRGY0KdBGbj8hviA806AwqzQ13ng93hIKJxlxoPB2hA7d/dQeprf
         lOIPvTPsQAwbUDRy4/LkdRBvx50GPx3HqK45FYZShBEqgFxqkMuPsdT2x+ULbffJ876c
         dhHnPhmG9GYZjJ3xj7sxXo0pk5y3MWAu1V/z+UZkIq4YeqGpVOrP30cQT8xsDbncmdgz
         63yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=aIrLAAwu70VUKOu1H0H/feK6SBkXI6yiMIucAia0RlQ=;
        fh=arZygn3P7UP6J5GD2NmrCkWtS8aoeRMzTnBM1gXrUXw=;
        b=Evxt+HAtEE6XzPDr02Gu1y9m7Trkq8IvBZbX6ZSgn+SKfgtL97gI9TiYZfQa2YPX9v
         anLxiGSzGE7eCYM1shrEQZE7ZHpGauIXrjYvSgo5Qi3FTKn5KbSl4B5Hdz3QZeocSGXA
         YYfzLEfO6U3o5GpmJYbitseFOXX7OcFMYr8cP4jPaD9T6gfrxxJJyfCKHSq7PZycxhwH
         CMwRQlqMRT+fF4fExL4L8IiHSPcDfuGcWoUCQpuIuRUTQHrL5v/wV9dbXBqjRIfm9soB
         pGuGzQNkZ/5Zqo5zMuzE3JKwNiyLCNPZfnNIkQeZcdbAZAQPWeMh5qbDsy/DJemxke3b
         gfxw==;
        dara=google.com
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20230601 header.b=JzflUVhj;
       spf=pass (google.com: domain of bartekn337@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=bartekn337@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com;
       dara=pass header.i=@herodotus.dev
Return-Path: <bartekn337@gmail.com>
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 38308e7fff4ca-307a3069e75sor4045991fa.2.2025.01.30.11.13.40
        for <bartosz@herodotus.dev>
        (Google Transport Security);
        Thu, 30 Jan 2025 11:13:40 -0800 (PST)
Received-SPF: pass (google.com: domain of bartekn337@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20230601 header.b=JzflUVhj;
       spf=pass (google.com: domain of bartekn337@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=bartekn337@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com;
       dara=pass header.i=@herodotus.dev
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1738264419; x=1738869219; darn=herodotus.dev;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=aIrLAAwu70VUKOu1H0H/feK6SBkXI6yiMIucAia0RlQ=;
        b=JzflUVhjslfIU/g88WLSF8JdhtqD8v1dvbz/lISNnERssprUw2I7Uab1DFrg6xhqgP
         I/buhHCXeW7fA8OZY1o4iiRvRxoVnL3xzrOmHvOJP13VZTq50faYo16bQDuINSqOKWTN
         PIO7cPLQIdq5+6i9YHCngj8Q1kB/RI2X5S7dI+Ga+OlwIdMAcCtUU690I3A9PXh82njg
         LhTgarHyGIHBKuExyrG06BP1R4foalJXIvjYMGAb6lWFfttr5tLYI5Op004eR9IjlXK4
         WSwkycNV6mH3Qyg6RLhgLwGFMLSpw16TyzWyayxP1i8q1mmgk2gEGpTF+i98pSHwqICm
         fIqA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1738264419; x=1738869219;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=aIrLAAwu70VUKOu1H0H/feK6SBkXI6yiMIucAia0RlQ=;
        b=xN5CCMmreigok89nWdGnXm1KSw2Sv2xYqcsycKGvBQsomyYrRhmYR/BKkpjLVKh+GQ
         yLGQ8+Qd3QIXXDEguVo494EgB+02Q0gt6PBFZpiB1QVvqWsU7vHNbb0DGh6hkXKmogQs
         m1eDGJu5xamSwOjtZ93hZaLkpLd9f7HToIlRZysMb4bkVHATpZZCNNZMB68mhlMhBV0x
         HqVW/gEXNpQmGg0Cjc7pO0MnMbb6NHvZPFIkI7YByzO1rayZ6upif07xWM/BW9DV+yTu
         USZx9hFRLYt9lgZBWa5xWGN2BFPK2qNUj4RnRXHsmFDqCg2SOQ3ktXrxMiQfrBxHuymq
         0+wQ==
X-Gm-Message-State: AOJu0YzCf/DQYfYPxEl4MYhs2mVfO45/SDWdH2S65oPCZ7VB7Vfw6vzT M1iy2tHGl/dj4n6hxXw4EPth8MAGrGcMjcw0OW/NNHVuylRNJHknX5riO6meCZ0Ff4Jycl5x3IP SBHNLUiedoroFgdpbU0+KLaNNqhGA/g==
X-Gm-Gg: ASbGnctdCaIOde9L+AXUCGMei7fZwvt6RCJaHRXgp1amJV2xegmlJ22YTLgsz0UDxSS YIjclFXpGuVaLE/r+komEuZsXWn0BW0y7m0CI3C+X0fucrRmPHY/EdWp9SsYZ3pARgn/SKyiO6A ==
X-Google-Smtp-Source: AGHT+IHHCGWSRK6Fgvjqo0n7qWi6H9+GR5NvYCnKNjZlI8YIetFTYcosqszOsDoDxntSNcBfBWza46ViE181UEohiYs=
X-Received: by 2002:a2e:b88c:0:b0:302:17e7:e17e with SMTP id 38308e7fff4ca-30796529c99mr31286031fa.0.1738264419308; Thu, 30 Jan 2025 11:13:39 -0800 (PST)
MIME-Version: 1.0
From: Bartek Nowak <bartekn337@gmail.com>
Date: Thu, 30 Jan 2025 20:13:27 +0100
X-Gm-Features: AWEUYZkQbPbjpz5QzoOYtKU2xF4yGzj1GbOVH6MWuX51pEQu7gSFsrzjRQqBh50
Message-ID: <CADaQ9zvN1gX+ofz=uz1=BnoJkezBBBPGSL2BOj51CW8YF-j49g@mail.gmail.com>
Subject: temat
To: bartosz@herodotus.dev
Content-Type: multipart/alternative; boundary="0000000000003d21cd062cf13950"

--0000000000003d21cd062cf13950
Content-Type: text/plain; charset="UTF-8"

random content

--0000000000003d21cd062cf13950
Content-Type: text/html; charset="UTF-8"

<div dir="ltr">random content</div>

--0000000000003d21cd062cf13950--"#;

#[tokio::test(flavor = "multi_thread", worker_threads = 1)]
async fn dkim_test() {
    // Create an authenticator using Cloudflare DNS
    let authenticator = MessageAuthenticator::new_cloudflare().unwrap();

    // Parse message
    let authenticated_message = AuthenticatedMessage::parse(TEST_MESSAGE.as_bytes()).unwrap();

    for (cb, _ha, l, _bh) in &authenticated_message.body_hashes {
        let mut body_bytes = Vec::with_capacity(1024);
        cb.canonical_body(authenticated_message.raw_body(), *l).write(&mut body_bytes);

        let body_len = body_bytes.len();
        preprocess(&mut body_bytes);

        println!(
            "body: {:?}",
            body_bytes
                .chunks(4)
                .map(|chunk| u32::from_be_bytes(chunk.try_into().unwrap()))
                .collect::<Vec<u32>>()
        );

        println!("body-advice: {} {}", 0, 0);
        println!("body-advice: {} {}", body_len / 4, body_len % 4);
    }

    for header in &authenticated_message.dkim_headers {
        let signature = header.header.as_ref().unwrap();

        let txt_lookup = authenticator.0.txt_lookup(signature.domain_key()).await.unwrap();

        let records: Vec<_> = txt_lookup
            .as_lookup()
            .record_iter()
            .filter_map(|r| {
                let txt_data = r.data()?.as_txt()?.txt_data();
                match txt_data.len() {
                    1 => Some(Cow::from(txt_data[0].as_ref())),
                    0 => None,
                    _ => {
                        let mut entry = Vec::with_capacity(255 * txt_data.len());
                        for data in txt_data {
                            entry.extend_from_slice(data);
                        }
                        Some(Cow::from(entry))
                    }
                }
            })
            .collect();

        let re = Regex::new(r"p=([a-zA-Z0-9+/=]+)").unwrap();
        let caps = re.captures(&records[0]).unwrap();

        let start_index = caps.get(0).unwrap().start();
        let end_index = caps.get(0).unwrap().end();

        let rsa_public_key =
            RsaPublicKey::from_public_key_der(&BASE64_STANDARD.decode(&records[0][start_index + 2..end_index]).unwrap()).unwrap();

        println!("n: {}", rsa_public_key.n());
        println!("e: {}", rsa_public_key.e());

        let signature_bytes = signature.signature();
        println!("signature: {}", BigUint::from_bytes_be(signature_bytes));

        let dkim_hdr_value = header.value.strip_signature();
        let headers = authenticated_message.signed_headers(&signature.h, header.name, &dkim_hdr_value);
        let mut header_bytes = Vec::with_capacity(1024);
        signature.ch.canonicalize_headers(headers, &mut header_bytes);

        preprocess(&mut header_bytes);

        let re = Regex::new(r"bh=([A-Za-z0-9+/=]+);").unwrap();
        let caps = re.captures(&header_bytes).unwrap();

        let start_index = caps.get(0).unwrap().start() + 3;
        let end_index = caps.get(0).unwrap().end() - 1;

        println!("body-hash-advice: {} {}", start_index / 4, start_index % 4);
        println!("body-hash-advice: {} {}", end_index / 4, end_index % 4);

        let re = Regex::new(r"d=([a-zA-Z0-9.-]+);").unwrap();
        let caps = re.captures(&header_bytes).unwrap();

        let start_index = caps.get(0).unwrap().start() + 2;
        let end_index = caps.get(0).unwrap().end() - 1;

        println!("domain-advice: {} {}", start_index / 4, start_index % 4);
        println!("domain-advice: {} {}", end_index / 4, end_index % 4);

        let re = Regex::new(r"darn=([a-zA-Z0-9.-]+);").unwrap();
        let caps = re.captures(&header_bytes).unwrap();

        let start_index = caps.get(0).unwrap().start() + 5;
        let end_index = caps.get(0).unwrap().end() - 1;

        println!("darn-advice: {} {}", start_index / 4, start_index % 4);
        println!("darn-advice: {} {}", end_index / 4, end_index % 4);

        println!(
            "header: {:?}",
            header_bytes
                .chunks(4)
                .map(|chunk| u32::from_be_bytes(chunk.try_into().unwrap()))
                .collect::<Vec<u32>>()
        );
    }

    // Validate signature
    let result = authenticator.verify_dkim(&authenticated_message).await;

    // Make sure all signatures passed verification
    assert!(result.iter().all(|s| s.result() == &DkimResult::Pass));
}

fn preprocess(message: &mut Vec<u8>) {
    let length = (message.len() * 8) as u64;
    message.push(0x80);

    while ((message.len() * 8) + 64) % 512 != 0 {
        message.push(0x00);
    }

    message.extend_from_slice(&length.to_be_bytes());

    assert!((message.len() * 8) % 512 == 0, "Padding did not complete properly!");
}
