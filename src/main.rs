use std::borrow::Cow;

use base64::prelude::*;
use mail_auth::{
    common::{headers::Writable, verify::VerifySignature},
    dkim::verify::Verifier,
    AuthenticatedMessage, DkimResult, MessageAuthenticator,
};
use regex::bytes::Regex;
use rsa::{pkcs8::DecodePublicKey, traits::PublicKeyParts, RsaPublicKey};

const TEST_MESSAGE: &str = r#"Delivered-To: bartosz@herodotus.dev
Received: by 2002:a17:907:1685:b0:ab6:41ea:5783 with SMTP id cx5csp230730ejd;
        Wed, 29 Jan 2025 05:19:37 -0800 (PST)
X-Received: by 2002:a05:651c:222c:b0:302:26ae:7bcd with SMTP id 38308e7fff4ca-307968c5b5amr13863691fa.23.1738156777170;
        Wed, 29 Jan 2025 05:19:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1738156777; cv=none;
        d=google.com; s=arc-20240605;
        b=SMsoQv/YSk4kjI0Hn6W4klKzByyC211WRtlodf63mp5BHd4/5lLI/gQEwOQtE2z8XG
         ERS5/xf4ZQjwZG1umaIhDjaioPtkWVJn1AHITiMIMvqeM4rovTvehJH9WKZZyno73xih
         ATpEWURUeVAqVa2RllJrrRpGM3jxnWhPxwgcEpn/oIcpuaGij5XqvUKhrflRaCtsuyrY
         EswSf4EX/2HHPiOE9yrvqYMA9Q2ZAeOfAfGU5swQQCOP7DyALZdzrq7eRScdFu4XKuZp
         Zdt8nAGB0cNydfnNA7A1v9s9QWC0AxAyYf7IF/4YGQUwM7eaKHqJ/njxKcdN/mcX4b0O
         W6Rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=xGnY0MtFN/OvVfFlXD7dhenIoSNz+zn36wvjrKyBMUY=;
        fh=arZygn3P7UP6J5GD2NmrCkWtS8aoeRMzTnBM1gXrUXw=;
        b=hoLDr+dMhqSDI6rXSf0dM+W0GzzQbGs8Fm8KVxYjqLlv6IJzP5zQvmoS/ztpn7Zd+i
         hKzHcrtYrxLO4dR0fEZlf5R6GOtAxyv0Waqb0FErUoj1kdnpq6R2QRff5MB/FVZ0jjT6
         7tWqKATZm3fh9ZSL7E+ng5JlxCq8mq4QA8v8X2AtyaoiRvXDjQMlQuGe03fLkwczzrnM
         5A5mN6mEvGoB+r3NwIdDm8g0TiLjsA4/yvaYl3nl3OdOY1EFSBkBQeL9l+QCf8/lpaW/
         EWXx5uJV2MVSOv8553afihUZOolhCWyFd3jijZzEgYwD26be47oTtvzjqFzSe9d8kUtw
         cqiQ==;
        dara=google.com
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20230601 header.b="NOuzke/t";
       spf=pass (google.com: domain of bartekn337@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=bartekn337@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com;
       dara=pass header.i=@herodotus.dev
Return-Path: <bartekn337@gmail.com>
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 38308e7fff4ca-3076bb8fc3asor26014451fa.10.2025.01.29.05.19.36
        for <bartosz@herodotus.dev>
        (Google Transport Security);
        Wed, 29 Jan 2025 05:19:37 -0800 (PST)
Received-SPF: pass (google.com: domain of bartekn337@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20230601 header.b="NOuzke/t";
       spf=pass (google.com: domain of bartekn337@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=bartekn337@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com;
       dara=pass header.i=@herodotus.dev
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1738156776; x=1738761576; darn=herodotus.dev;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=xGnY0MtFN/OvVfFlXD7dhenIoSNz+zn36wvjrKyBMUY=;
        b=NOuzke/tzRxtHy0pZw2KyyBe6iWLGoDQMYSM/RL14KMIiIt3PQpKnFIBt0gcV7sxg1
         cIkqwqDJqcKwyFDXY1aq+9zNmbAqC5bErn56K8icfL8X6wL/BFE/a4zmo8ur2E0PEool
         XXpIMdT6PYVC1wKbjaqKd+Pk/WRxdiZFkxdedEcVVcCObvtoYqe2z04XyXKBexTr2I9E
         kGFa2CvVvs6emLsgNNGjNeu5kT0+MgazQzUyjBwjobev08k+3byim2vq/EaAbyHKE7Y1
         rMOL4GNIl5HCNwW/Xm7n3kJsPvJeZAKz+2SF7sJSeDg1K2fE2KM1L6TyYU2hQkQroUQT
         0cqA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1738156776; x=1738761576;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=xGnY0MtFN/OvVfFlXD7dhenIoSNz+zn36wvjrKyBMUY=;
        b=ZYZiYKXp0bolA1QECVtn836NCjqAGt4cSZgKSRbfvr+A8/lHfF7IrvLWOUPnfyOyZ0
         eFThWUfoU+IXEVxGk+uhFWd5N9JVNL9iXMCHYho0gxb9jd/VJGE1Bc5rRq9m4cmWqRDZ
         c2SNQYDE+mluy9spOcBnMGljMTLi724UH53EXtwKvwBGZLLajefYenY3eaJ1qng9E0UQ
         LC7/QjTVE1lelvhgp4SUEcoF5xaOasXfPQ3SvdImoYm1eF4TDieN/+9rjWQVUobFTJtU
         eObg+gblQPOKrk7ntNEWGGj2BQhbwqXdEOP7aehF9A3ObHrlPpl8p1CjAc/aMDIpS2LY
         owTQ==
X-Gm-Message-State: AOJu0YwlFzK+mWEoPui+G0O93ruwFoUP6qX4ZLXicSymPChNMnA1k5+l 9WJcVgtw2D/iEb0zrlepnPnFTr9FenpMi8be3gFR36Qs6vuStmsACtPTM73d08tK8FcZ5j+hKXy DDF1Q2iPdo/IsN4p4WWVP+JH59r2s/Q==
X-Gm-Gg: ASbGncsGSq3OTt+hj7roRvfme/HR/kpYAQNb10OQFTh1YOGTpUaq9QwyeSeR5AUFEzx yAIuFEsS6cYw8IK3jkLO19l5QVGx2QCYQt7V2EnyEOy4YO7gR7I1FPI7GQo7OnklzvgOj6hJdBA ==
X-Google-Smtp-Source: AGHT+IEYY86Y+p59qKzMrtetoiHwpAp4O6IXm4aJAtcFsfjBwlq5zYchsnkZIErd7GTPmJydvysmBGjcCOH3cSpU024=
X-Received: by 2002:a05:651c:544:b0:300:15f1:cd5c with SMTP id 38308e7fff4ca-30796854f8cmr12028431fa.17.1738156776200; Wed, 29 Jan 2025 05:19:36 -0800 (PST)
MIME-Version: 1.0
From: Bartek Nowak <bartekn337@gmail.com>
Date: Wed, 29 Jan 2025 14:19:25 +0100
X-Gm-Features: AWEUYZk7XFge3L52flKfHJq-Y0ZMaw_dmSF_SSo85xZhKe_OmhEeWS92YgApR6g
Message-ID: <CADaQ9ztWHTJEOyB5DUR+MXgP=sWcSDUZMu-NDVpf2XohOppGGg@mail.gmail.com>
Subject: 
To: bartosz@herodotus.dev
Content-Type: multipart/alternative; boundary="00000000000035a17d062cd82988"

--00000000000035a17d062cd82988
Content-Type: text/plain; charset="UTF-8"

dupa

--00000000000035a17d062cd82988
Content-Type: text/html; charset="UTF-8"

<div dir="ltr">dupa</div>

--00000000000035a17d062cd82988--"#;

#[tokio::main]
async fn main() {
    // Create an authenticator using Cloudflare DNS
    let authenticator = MessageAuthenticator::new_cloudflare().unwrap();

    // Parse message
    let authenticated_message = AuthenticatedMessage::parse(TEST_MESSAGE.as_bytes()).unwrap();

    for (cb, _ha, l, _bh) in &authenticated_message.body_hashes {
        let mut body_bytes = Vec::with_capacity(1024);
        cb.canonical_body(authenticated_message.raw_body(), *l)
            .write(&mut body_bytes);
        preprocess(&mut body_bytes);
        println!(
            "body: {:?}",
            body_bytes
                .chunks(4)
                .map(|chunk| u32::from_be_bytes(chunk.try_into().unwrap()))
                .collect::<Vec<u32>>()
        );
    }

    for header in &authenticated_message.dkim_headers {
        let signature = header.header.as_ref().unwrap();

        let txt_lookup = authenticator
            .0
            .txt_lookup(signature.domain_key())
            .await
            .unwrap();

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

        let rsa_public_key = RsaPublicKey::from_public_key_der(
            &BASE64_STANDARD
                .decode(records[0][start_index + 2..end_index].to_vec())
                .unwrap(),
        )
        .unwrap();

        println!("{}", rsa_public_key.n());
        println!("{}", rsa_public_key.e());

        let signature_bytes = signature.signature();
        println!("signature: {:?}", hex::encode(signature_bytes));

        let dkim_hdr_value = header.value.strip_signature();
        let headers =
            authenticated_message.signed_headers(&signature.h, header.name, &dkim_hdr_value);
        let mut header_bytes = Vec::with_capacity(1024);
        signature
            .ch
            .canonicalize_headers(headers, &mut header_bytes);

        preprocess(&mut header_bytes);

        let re = Regex::new(r"bh=([A-Za-z0-9+/=]+);").unwrap();
        let caps = re.captures(&header_bytes).unwrap();

        let start_index = caps.get(0).unwrap().start() + 3;
        let end_index = caps.get(0).unwrap().end() - 1;

        println!("body-hash-advice: {} {}", start_index / 4, start_index % 4);
        println!("body-hash-advice: {} {}", end_index / 4, end_index % 4);

        let re = Regex::new(r"d=([a-zA-Z0-9.-]+);").unwrap();
        let caps = re.captures(&header_bytes).unwrap();

        let start_index = caps.get(0).unwrap().start();
        let end_index = caps.get(0).unwrap().end();

        println!("domain-advice: {} {}", start_index / 4, start_index % 4);
        println!("domain-advice: {} {}", end_index / 4, end_index % 4);

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

    assert!(
        (message.len() * 8) % 512 == 0,
        "Padding did not complete properly!"
    );
}
