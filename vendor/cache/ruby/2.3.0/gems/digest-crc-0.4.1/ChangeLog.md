### 0.4.1 / 2014-04-16

* Allow Digest CRC classes to be extended and their constants overriden.
* Allow {Digest::CRC5::CRC_MASK} to be overriden by subclasses.
* {Digest::CRC81Wire} now inherites from {Digest::CRC8}.

### 0.4.0 / 2013-02-13

* Added {Digest::CRC16QT}.

### 0.3.0 / 2011-09-24

* Added {Digest::CRC81Wire} (Henry Garner).

### 0.2.0 / 2011-05-10

* Added {Digest::CRC32c}.
* Opted into [test.rubygems.org](http://test.rubygems.org/)
* Switched from using Jeweler and Bundler, to using
  [Ore::Tasks](http://github.com/ruby-ore/ore-tasks).

### 0.1.0 / 2010-06-01

* Initial release.
  * CRC1
  * CRC5
  * CRC8
  * CRC16
  * CRC16 CCITT
  * CRC16 DNP
  * CRC16 Modbus
  * CRC16 USB
  * CRC16 XModem
  * CRC16 ZModem
  * CRC24
  * CRC32
  * CRC32 Mpeg
  * CRC64

