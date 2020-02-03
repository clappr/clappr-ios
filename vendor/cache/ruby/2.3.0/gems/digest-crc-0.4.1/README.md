# Digest CRC

* [Source](https://github.com/postmodern/digest-crc)
* [Issues](https://github.com/postmodern/digest-crc/issues)
* [Documentation](http://rubydoc.info/gems/digest-crc/frames)
* [Email](mailto:postmodern.mod3 at gmail.com)

## Description

Adds support for calculating Cyclic Redundancy Check (CRC) to the Digest
module.

## Features

* Provides support for the following CRC algorithms:
  * {Digest::CRC1 CRC1}
  * {Digest::CRC5 CRC5}
  * {Digest::CRC8 CRC8}
  * {Digest::CRC81Wire CRC8 1-Wire}
  * {Digest::CRC16 CRC16}
  * {Digest::CRC16CCITT CRC16 CCITT}
  * {Digest::CRC16DNP CRC16 DNP}
  * {Digest::CRC16Modbus CRC16 Modbus}
  * {Digest::CRC16USB CRC16 USB}
  * {Digest::CRC16XModem CRC16 XModem}
  * {Digest::CRC16ZModem CRC16 ZModem}
  * {Digest::CRC16QT CRC16 QT}
  * {Digest::CRC24 CRC24}
  * {Digest::CRC32 CRC32}
  * {Digest::CRC32c CRC32c}
  * {Digest::CRC32Mpeg CRC32 Mpeg}
  * {Digest::CRC64 CRC64}
* Pure Ruby implementation.
* Provides CRC Tables for optimized calculations.

## Install

```
gem install digest-crc
```

## Examples

Calculate a CRC32:

```ruby
require 'digest/crc32'

Digest::CRC32.hexdigest('hello')
# => "3610a686"
```

Calculate a CRC32 of a file:

```ruby
Digest::CRC32.file('README.md')
# => #<Digest::CRC32: 127ad531>
```

Incrementally calculate a CRC32:

```ruby
crc = Digest::CRC32.new
crc << 'one'
crc << 'two'
crc << 'three'
crc.hexdigest
# => "09e1c092"
```

Directly access the checksum:

```ruby
crc.checksum
# => 165789842
```

Defining your own CRC class:

```ruby
require 'digest/crc32'

module Digest
  class CRC3000 < CRC32

    WIDTH = 4

    INIT_CRC = 0xffffffff

    XOR_MASK = 0xffffffff

    TABLE = [
      # ....
    ].freeze

    def update(data)
      data.each_byte do |b|
        @crc = (((@crc >> 8) & 0x00ffffff) ^ @table[(@crc ^ b) & 0xff])
      end

      return self
    end
  end
end
```

## Thanks

Special thanks go out to the [pycrc](http://www.tty1.net/pycrc/) library
which is able to generate C source-code for all of the CRC algorithms,
including their CRC Tables.

## License

Copyright (c) 2010-2014 Hal Brodigan

See [LICENSE.txt](LICENSE.txt) for license information.
