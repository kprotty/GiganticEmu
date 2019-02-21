#!/usr/bin/ruby
# Quick rewrite of a salsa library as client uses nonstandard round count post auth, 12 for authentication and 15 for post auth.
# Client implements odd and even rounds in same block, decrementing twice until not above zero, so 15=16.

class Salsa
  def initialize(key,rounds)
    @rounds = rounds

    c = [0x61707865, 0x3120646e, 0x79622d36, 0x6b206574]

    k = Array.new()
    key.scan(/..../).each { |b|
      k.push(little_endian(b))
    }

    @matrix = [c[0], k[0], k[1], k[2],
               k[3], c[1],  0,    0,
                 0,    0,  c[2], k[0],
               k[1], k[2], k[3], c[3]]
  end

  def encrypt(data_in)
    data_out = ''
    while data_in
      stream = self.salsa_block()
      @matrix[8] += 1
      # TODO: figure out how client handles position overflow.
      if @matrix[8] == 0
        @matrix[9] += 1
      end
      data_out += xor(stream, data_in[0..63])
      if data_in.length <= 64
        return data_out
      end
      data_in = data_in[64..data_in.length+63]
    end
  end

  alias_method :decrypt, :encrypt

  def xor(stream, din)
    out = []
    for i in 0..din.length-1 do
      c = (stream[i].ord ^ din[i].ord).chr
      out.push(c)
    end
    return out.join
  end

  def little_endian(b)
    little_endian = b[0].ord ^ (b[1].ord << 8) ^ (b[2].ord << 16) ^ (b[3].ord << 24)
  end

  def rotate_left(a,b)
        ((a << b) | (a >> (32 - b))) & 0xffffffff
  end

  def salsa_block()
    x = @matrix.clone

    (0..@rounds -1).step(2) do |i|
      x[ 4] ^= self.rotate_left( (x[ 0]+x[12]) & 0xffffffff,  7)
      x[ 8] ^= self.rotate_left( (x[ 4]+x[ 0]) & 0xffffffff,  9)
      x[12] ^= self.rotate_left( (x[ 8]+x[ 4]) & 0xffffffff, 13)
      x[ 0] ^= self.rotate_left( (x[12]+x[ 8]) & 0xffffffff, 18)
      x[ 9] ^= self.rotate_left( (x[ 5]+x[ 1]) & 0xffffffff,  7)
      x[13] ^= self.rotate_left( (x[ 9]+x[ 5]) & 0xffffffff,  9)
      x[ 1] ^= self.rotate_left( (x[13]+x[ 9]) & 0xffffffff, 13)
      x[ 5] ^= self.rotate_left( (x[ 1]+x[13]) & 0xffffffff, 18)
      x[14] ^= self.rotate_left( (x[10]+x[ 6]) & 0xffffffff,  7)
      x[ 2] ^= self.rotate_left( (x[14]+x[10]) & 0xffffffff,  9)
      x[ 6] ^= self.rotate_left( (x[ 2]+x[14]) & 0xffffffff, 13)
      x[10] ^= self.rotate_left( (x[ 6]+x[ 2]) & 0xffffffff, 18)
      x[ 3] ^= self.rotate_left( (x[15]+x[11]) & 0xffffffff,  7)
      x[ 7] ^= self.rotate_left( (x[ 3]+x[15]) & 0xffffffff,  9)
      x[11] ^= self.rotate_left( (x[ 7]+x[ 3]) & 0xffffffff, 13)
      x[15] ^= self.rotate_left( (x[11]+x[ 7]) & 0xffffffff, 18)

      x[ 1] ^= self.rotate_left( (x[ 0]+x[ 3]) & 0xffffffff,  7)
      x[ 2] ^= self.rotate_left( (x[ 1]+x[ 0]) & 0xffffffff,  9)
      x[ 3] ^= self.rotate_left( (x[ 2]+x[ 1]) & 0xffffffff, 13)
      x[ 0] ^= self.rotate_left( (x[ 3]+x[ 2]) & 0xffffffff, 18)
      x[ 6] ^= self.rotate_left( (x[ 5]+x[ 4]) & 0xffffffff,  7)
      x[ 7] ^= self.rotate_left( (x[ 6]+x[ 5]) & 0xffffffff,  9)
      x[ 4] ^= self.rotate_left( (x[ 7]+x[ 6]) & 0xffffffff, 13)
      x[ 5] ^= self.rotate_left( (x[ 4]+x[ 7]) & 0xffffffff, 18)
      x[11] ^= self.rotate_left( (x[10]+x[ 9]) & 0xffffffff,  7)
      x[ 8] ^= self.rotate_left( (x[11]+x[10]) & 0xffffffff,  9)
      x[ 9] ^= self.rotate_left( (x[ 8]+x[11]) & 0xffffffff, 13)
      x[10] ^= self.rotate_left( (x[ 9]+x[ 8]) & 0xffffffff, 18)
      x[12] ^= self.rotate_left( (x[15]+x[14]) & 0xffffffff,  7)
      x[13] ^= self.rotate_left( (x[12]+x[15]) & 0xffffffff,  9)
      x[14] ^= self.rotate_left( (x[13]+x[12]) & 0xffffffff, 13)
      x[15] ^= self.rotate_left( (x[14]+x[13]) & 0xffffffff, 18)
    end

    for i in 0..15 do
      x[i] = (x[i] + @matrix[i]) & 0xffffffff
    end

    x = [x[ 0], x[ 1], x[ 2], x[ 3],
         x[ 4], x[ 5], x[ 6], x[ 7],
         x[ 8], x[ 9], x[10], x[11],
         x[12], x[13], x[14], x[15]].pack('L16')
  end
end
