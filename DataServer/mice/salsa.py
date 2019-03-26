import array
import struct

class Salsa:
    def __init__(self, key, rounds):
        k0, k1, k2, k3 = struct.unpack('<IIII', key.encode())
        c0, c1, c2, c3 = (0x61707865, 0x3120646e, 0x79622d36, 0x6b206574)

        self.rounds = rounds
        self.matrix = [
            c0, k0, k1, k2,
            k3, c1,  0,  0,
             0,  0, c2, k0,
            k1, k2, k3, c3
        ]

    def decrypt(self, data):
        return self.encrypt(data)

    def encrypt(self, data):
        output = []
        while True:
            block = self.salsa_block()
            self.update_matrix()
            output.append(self.xor(block, data[:64]))
            if len(data) <= 64:
                return b''.join(output)
            data = data[64:]

    def update_matrix(self):
        # TODO: figure out how client handles position overflow
        self.matrix[8] += 1
        if self.matrix[8] == 0:
            self.matrix[9] += 1

    def xor(self, block, chunk):
        block = block[:len(chunk)]
        for index in range(len(block)):
            block[index] ^= chunk[index]
        return block

    def salsa_block(self):
        block = self.matrix.copy()
        for _ in range(0, self.rounds, 2):
            self.salsa_round(block)
        for index in range(len(block)):
            block[index] = (block[index] + self.matrix[index]) & 0xffffffff
        return bytearray(array.array('L', block).tostring())

    @staticmethod
    def salsa_merge(block, assign, left, right, shift):
        value = (block[left] + block[right]) & 0xffffffff
        value = ((value << shift) | (value >> (32 - shift))) & 0xffffffff
        block[assign] ^= value

    def salsa_round(self, block):
        self.salsa_merge(block,  4,  0, 12,  7)
        self.salsa_merge(block,  8,  4,  0,  9)
        self.salsa_merge(block, 12,  8,  4, 13)
        self.salsa_merge(block,  0, 12,  8, 18)
        self.salsa_merge(block,  9,  5,  1,  7)
        self.salsa_merge(block, 13,  9,  5,  9)
        self.salsa_merge(block,  1, 13,  9, 13)
        self.salsa_merge(block,  5,  1, 13, 18)
        self.salsa_merge(block, 14, 10,  6,  7)
        self.salsa_merge(block,  2, 14, 10,  9)
        self.salsa_merge(block,  6,  2, 14, 13)
        self.salsa_merge(block, 10,  6,  2, 18)
        self.salsa_merge(block,  3, 15, 11,  7)
        self.salsa_merge(block,  7,  3, 15,  9)
        self.salsa_merge(block, 11,  7,  3, 13)
        self.salsa_merge(block, 15, 11,  7, 18)

        self.salsa_merge(block,  1,  0,  3,  7)
        self.salsa_merge(block,  2,  1,  0,  9)
        self.salsa_merge(block,  3,  2,  1, 13)
        self.salsa_merge(block,  0,  3,  2, 18)
        self.salsa_merge(block,  6,  5,  4,  7)
        self.salsa_merge(block,  7,  6,  5,  9)
        self.salsa_merge(block,  4,  7,  6, 13)
        self.salsa_merge(block,  5,  4,  7, 18)
        self.salsa_merge(block, 11, 10,  9,  7)
        self.salsa_merge(block,  8, 11, 10,  9)
        self.salsa_merge(block,  9,  8, 11, 13)
        self.salsa_merge(block, 10,  9,  8, 18)
        self.salsa_merge(block, 12, 15, 14,  7)
        self.salsa_merge(block, 13, 12, 15,  9)
        self.salsa_merge(block, 14, 13, 12, 13)
        self.salsa_merge(block, 15, 14, 13, 18)
            
