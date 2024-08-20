instructions = []
data = {}

instruction_set = {
    'nop' : {'code': "00", 'addr': False},
    'ldac': {'code': "01", 'addr': True},
    'stac': {'code': "02", 'addr': True},
    'mvac': {'code': "03", 'addr': False},
    'movr': {'code': "04", 'addr': False},
    'jump': {'code': "05", 'addr': True},
    'jmpz': {'code': "06", 'addr': True},
    'jpnz': {'code': "07", 'addr': True},
    'add': {'code': "08", 'addr': False},
    'sub': {'code': "09", 'addr': False},
    'inac': {'code': "0A", 'addr': False},
    'clac': {'code': "0B", 'addr': False},
    'and': {'code': "0C", 'addr': False},
    'or': {'code': "0D", 'addr': False},
    'xor': {'code': "0E", 'addr': False},
    'not': {'code': "0F", 'addr': False}
}

TOTAL_LINES = 65536
with open('test_program.asm','r') as f_in, open('hex_mem.txt', 'w') as f_out:
    for line in f_in:
        line = line.strip().lower()
        if line and not line.startswith(';'):  # Ignore lines starting with ';'
            line = line.split(';')[0]  # Remove any comments
            line = line.split()
            if line[0] in instruction_set:
                instructions.append(instruction_set[line[0]]['code'])
                if instruction_set[line[0]]['addr']:
                    addr = int(line[1], 16)
                    instructions.append(f'{addr & 0xFF:02x}')
                    instructions.append(f'{addr >> 8:02x}')
            elif len(line)==2 and ':' in line[0]:
                addr = int(line[0].split(':')[0], 16)
                value = int(line[1], 16)
                data[addr] = f'{value:02x}'

    for i in range(TOTAL_LINES):
        if i < len(instructions):
            print(instructions[i])
            f_out.write(instructions[i] + '\n')
        elif i in data:
            print(data[i])
            f_out.write(data[i] + '\n')
        else:
            f_out.write("00\n")
