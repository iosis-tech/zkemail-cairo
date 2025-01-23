SIZE = 64

def generate_cases():
    code = []
    for i in range(SIZE):
        terms = []
        for j in range(i + 1):
            terms.append(f"a{j:02} * b{i - j:02}")
        terms.append("carry")
        code.append(f"let (res{i:02}, carry) = split_64({" + ".join(terms)});")
    return "\n".join(code)

def generate_cases_backwards():
    code = []
    for i in range(SIZE - 1, -1, -1):
        terms = []
        for j in range(i, -1, -1):
            terms.append(f"a{SIZE - 1 - j:02} * b{SIZE - 1 - (i - j):02}")
        terms.append("carry")
        code.append(f"let (res{SIZE * 2 - 2 - i:02}, carry) = split_64({" + ".join(terms)});")
    return "\n".join(code)

if __name__ == "__main__":
    cases = generate_cases_backwards()
    print(cases)

