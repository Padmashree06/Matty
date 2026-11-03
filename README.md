# Matty

An interpreter written in OCaml for mathematical expressions.

Matty evaluates arithmetic expressions according to the standard order of operations (BODMAS/PEMDAS), with support for parentheses and basic mathematical operations.

## Getting Started

### Prerequisites
- OCaml compiler (`ocamlc`)

### Build

```bash
git clone https://github.com/Padmashree06/Matty.git
cd Matty
ocamlc -o matty interpreter.ml
```

### Add to PATH (Optional)

To run `matty` from any directory, move the executable to your local bin and update your profile:

```bash
mkdir -p ~/.local/bin
cp matty ~/.local/bin/matty
```

Add `~/.local/bin` to your PATH:

```bash
echo 'export PATH="HOME/.local/bin:PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Run

Run the included `test.my` file to verify the installation:

```bash
# If added to PATH:
matty test.my

# If running locally from the build directory:
./matty test.my
```

You can also create your own `.my` files and run them using:

```bash
matty <fileName>.my
```

## Supported Operations

| Operator | Operation |
|---|---|
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |
| `%` | Modulo |
| `()` | Parentheses |
