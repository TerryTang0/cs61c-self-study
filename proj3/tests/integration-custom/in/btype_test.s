addi s1, x0, 5          # 1,  0x00, s1 = 5
addi s2, x0, 5          # 2,  0x04, s2 = 5
addi s3, x0, 7          # 3,  0x08, s3 = 7
addi s4, x0, -1         # 4,  0x0C, s4 = -1

beq  s1, s2, beq_taken  # 5,  0x10, should be taken
addi s0, x0, 111        # skipped if beq works

beq_taken:
    addi s0, x0, 1          # 6,  0x18, s0 = 1

    bne  s1, s3, bne_taken  # 7,  0x1C, should be taken
    addi s0, x0, 111        # skipped if bne works

bne_taken:
    addi s0, x0, 2          # 8,  0x24, s0 = 2
    blt  s4, s1, blt_taken  # 9,  0x28, should be taken
    addi s0, x0, 111        # skipped if blt works

blt_taken:
    addi s0, x0, 3          # 10, 0x30, s0 = 3
    bge  s3, s1, bge_taken  # 11, 0x34, should be taken
    addi s0, x0, 111        # skipped if bge works

bge_taken:
    addi s0, x0, 4          # 12, 0x3C, s0 = 4
    bltu s1, s4, bltu_taken # 13, 0x40, should be taken
    addi s0, x0, 111        # skipped if bltu works

bltu_taken:
    addi s0, x0, 5          # 14, 0x48, s0 = 5
    bgeu s4, s1, bgeu_taken # 15, 0x4C, should be taken
    addi s0, x0, 111        # skipped if bgeu works
bgeu_taken:
    addi s0, x0, 6          # 16, 0x54, s0 = 6