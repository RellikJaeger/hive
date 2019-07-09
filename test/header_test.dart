import 'dart:typed_data';

import 'package:hive/src/binary/binary_reader_impl.dart';
import 'package:hive/src/io/header.dart';
import 'package:test/test.dart';

import 'common.dart';

class HeaderTest {
  final Header header;
  final List<int> keyHash;
  final List<int> bytes;

  const HeaderTest(this.header, this.keyHash, this.bytes);

  int get checksum {
    var checksumBytes = bytes.sublist(bytes.length - 4, bytes.length);
    return BinaryReaderImpl(checksumBytes, null).readUnsignedInt32();
  }
}

void expectHeadersEqual(Header h1, Header h2) {
  expect(h1.fileVersion, h2.fileVersion);
  expect(h1.dataVersion, h2.dataVersion);
  expect(h1.encrypted, h2.encrypted);
}

var headerList = [
  HeaderTest(
    Header(1, 1, false),
    null,
    [1, 1, 0, 0, 120, 7, 9, 8],
  ),
  HeaderTest(
    Header(73, 260, false),
    null,
    [73, 4, 1, 0, 108, 185, 252, 10],
  ),
  HeaderTest(
    Header(1, 1, true),
    List<int>.generate(
        32, (i) => i == 0 ? 12 : i == 1 ? 25 : i == 2 ? 97 : i == 3 ? 11 : i),
    [1, 1, 0, 1, 116, 30, 12, 46],
  ),
  HeaderTest(
    Header(6, 258, true),
    List<int>.generate(
        32, (i) => i == 0 ? 10 : i == 1 ? 100 : i == 2 ? 94 : i == 3 ? 215 : i),
    [6, 2, 1, 1, 22, 135, 143, 223],
  ),
];

void main() {
  test('fromBytes', () {
    for (var ht in headerList) {
      Uint8List key = ht.keyHash != null ? u8(ht.keyHash) : null;
      var header = Header.fromBytes(u8(ht.bytes), keyHash: key);
      expectHeadersEqual(header, ht.header);
    }

    var wrongChecksumBytes = u8([1, 1, 0, 0, 1, 2, 3, 4]);
    expect(() => Header.fromBytes(wrongChecksumBytes),
        throwsHiveError("checksum"));

    var unencryptedBytes = u8([1, 1, 0, 0, 82, 12, 212, 98]);
    expect(() => Header.fromBytes(unencryptedBytes, keyHash: u8([1, 2, 3])),
        throwsHiveError("cannot open unencrypted"));

    var encryptedBytes = u8([1, 1, 0, 1, 94, 21, 209, 68]);
    expect(() => Header.fromBytes(encryptedBytes),
        throwsHiveError("cannot open encrypted"));
  });

  test('toBytes', () {
    for (var ht in headerList) {
      var key = ht.keyHash != null ? u8(ht.keyHash) : null;
      var bxtes = ht.header.toBytes(keyHash: key).toList();
      expect(bxtes, ht.bytes);
    }
  });

  test('calculateChecksum', () {
    for (var ht in headerList) {
      var key = ht.keyHash != null ? u8(ht.keyHash) : null;
      var checksum = ht.header.calculateChecksum(key);
      expect(checksum & 0xFF, ht.bytes[4]);
      expect((checksum >> 8) & 0xFF, ht.bytes[5]);
      expect((checksum >> 16) & 0xFF, ht.bytes[6]);
      expect((checksum >> 24) & 0xFF, ht.bytes[7]);
    }
  });
}
