import 'dart:math';
import 'dart:typed_data';

import 'package:hive/src/binary/binary_writer_impl.dart';
import 'package:hive/src/io/frame.dart';
import 'package:hive/src/registry/type_registry_impl.dart';
import 'package:test/test.dart';

List<int> bytes(ByteData byteData) => byteData.buffer.asUint8List();

BinaryWriterImpl getWriter() => BinaryWriterImpl(TypeRegistryImpl());

void main() {
  test("write byte", () {
    var bw = getWriter();

    bw.writeByte(0);
    expect(bw.writtenBytes, 1);
    expect(bw.outputAndClear(), [0]);

    bw.writeByte(17);
    expect(bw.outputAndClear(), [17]);

    bw.writeByte(255);
    expect(bw.outputAndClear(), [255]);

    bw.writeByte(257);
    expect(bw.outputAndClear(), [1]);

    expect(() => bw.writeByte(null), throwsA(anything));
  });

  test("write bytes", () {
    var bw = getWriter();

    bw.writeBytes(Uint8List.fromList([0, 17, 255, 257]));
    expect(bw.writtenBytes, 4);
    expect(bw.outputAndClear(), [0, 17, 255, 1]);

    expect(() => bw.writeBytes(null), throwsA(anything));
  });

  test("write word", () {
    var bw = getWriter();

    bw.writeWord(0);
    expect(bw.writtenBytes, 2);
    expect(bw.outputAndClear(), [0, 0]);

    bw.writeWord(256);
    expect(bw.outputAndClear(), [0, 1]);

    bw.writeWord(65535);
    expect(bw.outputAndClear(), [255, 255]);

    bw.writeWord(65536);
    expect(bw.outputAndClear(), [0, 0]);

    expect(() => bw.writeWord(null), throwsA(anything));
  });

  test("write int32", () {
    var bd = ByteData(4);
    var bw = getWriter();

    bw.writeInt32(0);
    bd.setInt32(0, 0, Endian.little);
    expect(bw.writtenBytes, 4);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeInt32(1);
    bd.setInt32(0, 1, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeInt32(-1);
    bd.setInt32(0, -1, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeInt32(65535);
    bd.setInt32(0, 65535, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeInt32(65536);
    bd.setInt32(0, 65536, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeInt32(-65536);
    bd.setInt32(0, -65536, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeInt32(-65537);
    bd.setInt32(0, -65537, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    expect(() => bw.writeInt32(null), throwsA(anything));
  });

  test("write unsigned int32", () {
    var bd = ByteData(4);
    var bw = getWriter();

    bw.writeUnsigenedInt32(0);
    bd.setUint32(0, 0, Endian.little);
    expect(bw.writtenBytes, 4);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeUnsigenedInt32(1);
    bd.setUint32(0, 1, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeUnsigenedInt32(2147483647);
    bd.setUint32(0, 2147483647, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeUnsigenedInt32(-2147483648);
    bd.setUint32(0, -2147483648, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    expect(() => bw.writeUnsigenedInt32(null), throwsA(anything));
  });

  test("write int", () {
    var bd = ByteData(8);
    var bw = getWriter();

    bw.writeInt(0);
    bd.setInt64(0, 0, Endian.little);
    expect(bw.writtenBytes, 8);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeInt(1);
    bd.setInt64(0, 1, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeInt(-1);
    bd.setInt64(0, -1, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeInt(-(pow(-2, 63) + 1));
    bd.setInt64(0, -(pow(-2, 63) + 1), Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeInt(pow(-2, 63));
    bd.setInt64(0, pow(-2, 63), Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    expect(() => bw.writeInt(null), throwsA(anything));
  });

  test("write double", () {
    var bd = ByteData(8);
    var bw = getWriter();

    bw.writeDouble(0);
    bd.setFloat64(0, 0, Endian.little);
    expect(bw.writtenBytes, 8);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeDouble(16.399483);
    bd.setFloat64(0, 16.399483, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeDouble(double.nan);
    bd.setFloat64(0, double.nan, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeDouble(double.infinity);
    bd.setFloat64(0, double.infinity, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeDouble(double.negativeInfinity);
    bd.setFloat64(0, double.negativeInfinity, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeDouble(double.maxFinite);
    bd.setFloat64(0, double.maxFinite, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    bw.writeDouble(double.minPositive);
    bd.setFloat64(0, double.minPositive, Endian.little);
    expect(bw.outputAndClear(), bytes(bd));

    expect(() => bw.writeDouble(null), throwsA(anything));
  });

  test("write bool", () {
    var bw = getWriter();

    bw.writeBool(true);
    expect(bw.outputAndClear(), [1]);

    bw.writeBool(false);
    expect(bw.outputAndClear(), [0]);

    expect(() => bw.writeBool(null), throwsA(anything));
  });

  test("write ascii string", () {
    var bw = getWriter();

    bw.writeAsciiString("");
    expect(bw.outputAndClear(), [0, 0]);

    bw.writeAsciiString("", writeLength: false);
    expect(bw.outputAndClear(), []);

    bw.writeAsciiString("T.,r \n");
    expect(bw.outputAndClear(), [6, 0, 84, 46, 44, 114, 32, 10]);

    bw.writeAsciiString("T.,r \n", writeLength: false);
    expect(bw.outputAndClear(), [84, 46, 44, 114, 32, 10]);

    expect(() => bw.writeAsciiString("😍"), throwsA(anything));
    expect(() => bw.writeAsciiString(null), throwsA(anything));
  });

  test("write string", () {
    var bw = getWriter();

    bw.writeString("");
    expect(bw.outputAndClear(), [0, 0]);

    bw.writeString("", writeByteCount: false);
    expect(bw.outputAndClear(), []);

    bw.writeString("𠁠🇬🇵");
    expect(bw.outputAndClear(), [
      12, 0, 0xf0, 0xa0, 0x81, 0xa0, 0xf0, //
      0x9f, 0x87, 0xac, 0xf0, 0x9f, 0x87, 0xb5 //
    ]);

    bw.writeString("👨‍👨‍👧‍👦", writeByteCount: false);
    expect(bw.outputAndClear(), [
      0xf0, 0x9f, 0x91, 0xa8, 0xe2, 0x80, 0x8d, 0xf0, 0x9f, 0x91, 0xa8, //
      0xe2, 0x80, 0x8d, 0xf0, 0x9f, 0x91, 0xa7, 0xe2, 0x80, 0x8d, 0xf0, //
      0x9f, 0x91, 0xa6 //
    ]);

    expect(() => bw.writeString(null), throwsA(anything));
  });

  test("write int list", () {
    var bw = getWriter();

    bw.writeIntList([]);
    expect(bw.outputAndClear(), [0, 0]);

    bw.writeIntList([], writeLength: false);
    expect(bw.outputAndClear(), []);

    bw.writeIntList([1, 2]);
    expect(bw.outputAndClear(),
        [2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0]);

    bw.writeIntList([1, 2], writeLength: false);
    expect(
        bw.outputAndClear(), [1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0]);

    expect(() => bw.writeIntList(null), throwsA(anything));
  });

  test("write double list", () {
    var bw = getWriter();

    bw.writeDoubleList([]);
    expect(bw.outputAndClear(), [0, 0]);

    bw.writeDoubleList([], writeLength: false);
    expect(bw.outputAndClear(), []);

    bw.writeDoubleList([1.0]);
    expect(bw.outputAndClear(), [1, 0, 0, 0, 0, 0, 0, 0, 240, 63]);

    bw.writeDoubleList([1.0], writeLength: false);
    expect(bw.outputAndClear(), [0, 0, 0, 0, 0, 0, 240, 63]);

    expect(() => bw.writeDoubleList(null), throwsA(anything));
  });

  test("write bool list", () {
    var bw = getWriter();

    bw.writeBoolList([]);
    expect(bw.outputAndClear(), [0, 0]);

    bw.writeBoolList([], writeLength: false);
    expect(bw.outputAndClear(), []);

    bw.writeBoolList([true, false, true]);
    expect(bw.outputAndClear(), [3, 0, 1, 0, 1]);

    bw.writeBoolList([true, false, true], writeLength: false);
    expect(bw.outputAndClear(), [1, 0, 1]);

    expect(() => bw.writeBoolList(null), throwsA(anything));
  });

  test("write string list", () {
    var bw = getWriter();

    bw.writeStringList([]);
    expect(bw.outputAndClear(), [0, 0]);

    bw.writeStringList([], writeLength: false);
    expect(bw.outputAndClear(), []);

    bw.writeStringList(["a", "🧙‍♂️"]);
    expect(bw.outputAndClear(), [
      2, 0, 1, 0, 97, 13, 0, 0xf0, 0x9f, 0xa7, 0x99, 0xe2, 0x80, 0x8d, 0xe2, //
      0x99, 0x82, 0xef, 0xb8, 0x8f //
    ]);

    bw.writeStringList(["a", "ab"], writeLength: false);
    expect(bw.outputAndClear(), [1, 0, 97, 2, 0, 97, 98]);

    expect(() => bw.writeBoolList(null), throwsA(anything));
  });

  test("write list", () {
    var bw = getWriter();

    bw.writeList(["h", true]);
    expect(bw.outputAndClear(), [
      2, 0, FrameValueType.string_.index, //
      1, 0, 0x68, FrameValueType.bool_.index, 1 //
    ]);

    bw.writeList(["h", true], writeLength: false);
    expect(bw.outputAndClear(), [
      FrameValueType.string_.index, //
      1, 0, 0x68, FrameValueType.bool_.index, 1 //
    ]);
  });

  test("write map", () {
    var bw = getWriter();

    bw.writeMap({true: "h", "hi": true});
    expect(bw.outputAndClear(), [
      2, 0, FrameValueType.bool_.index, 1, FrameValueType.string_.index, //
      1, 0, 0x68, FrameValueType.string_.index, 2, 0, 0x68, 0x69, //
      FrameValueType.bool_.index, 1 //
    ]);

    bw.writeMap({true: "h", "hi": true}, writeLength: false);
    expect(bw.outputAndClear(), [
      FrameValueType.bool_.index, 1, FrameValueType.string_.index, //
      1, 0, 0x68, FrameValueType.string_.index, 2, 0, 0x68, 0x69, //
      FrameValueType.bool_.index, 1 //
    ]);
  });

  group("write value", () {
    test("null", () {
      var bw = getWriter();

      bw.write(null, writeTypeId: false);
      expect(bw.outputAndClear(), []);

      bw.write(null, writeTypeId: true);
      expect(bw.outputAndClear(), [FrameValueType.null_.index]);
    });

    test("int", () {
      var bd = ByteData(8)..setInt64(0, 12345, Endian.little);
      var bw = getWriter();

      bw.write(12345, writeTypeId: false);
      expect(bw.outputAndClear(), bytes(bd));

      bw.write(12345, writeTypeId: true);
      expect(bw.outputAndClear(), [FrameValueType.int_.index, ...bytes(bd)]);
    });

    test("double", () {
      var bd = ByteData(8)..setFloat64(0, 123.456, Endian.little);
      var bw = getWriter();

      bw.write(123.456, writeTypeId: false);
      expect(bw.outputAndClear(), bytes(bd));

      bw.write(123.456, writeTypeId: true);
      expect(bw.outputAndClear(), [FrameValueType.double_.index, ...bytes(bd)]);
    });

    test("bool", () {
      var bw = getWriter();

      bw.write(true, writeTypeId: false);
      expect(bw.outputAndClear(), [1]);

      bw.write(true, writeTypeId: true);
      expect(bw.outputAndClear(), [FrameValueType.bool_.index, 1]);
    });

    test("string", () {
      var bw = getWriter();

      bw.write("hi", writeTypeId: false);
      expect(bw.outputAndClear(), [2, 0, 0x68, 0x69]);

      bw.write("hi", writeTypeId: true);
      expect(bw.outputAndClear(),
          [FrameValueType.string_.index, 2, 0, 0x68, 0x69]);
    });

    test("int list", () {
      var bd = ByteData(18)
        ..setUint16(0, 2, Endian.little)
        ..setInt64(2, 123, Endian.little)
        ..setInt64(10, 45, Endian.little);
      var bw = getWriter();

      bw.write([123, 45], writeTypeId: false);
      expect(bw.outputAndClear(), bytes(bd));

      bw.write([123, 45], writeTypeId: true);
      expect(
          bw.outputAndClear(), [FrameValueType.int_list_.index, ...bytes(bd)]);
    });

    test("double list", () {
      var bd = ByteData(18)
        ..setUint16(0, 2, Endian.little)
        ..setFloat64(2, 123.456, Endian.little)
        ..setFloat64(10, 456.321, Endian.little);
      var bw = getWriter();

      bw.write([123.456, 456.321], writeTypeId: false);
      expect(bw.outputAndClear(), bytes(bd));

      bw.write([123.456, 456.321], writeTypeId: true);
      expect(bw.outputAndClear(),
          [FrameValueType.double_list_.index, ...bytes(bd)]);
    });

    test("bool list", () {
      var bd = ByteData(4)
        ..setUint16(0, 2, Endian.little)
        ..setUint8(2, 0)
        ..setUint8(3, 1);
      var bw = getWriter();

      bw.write([false, true], writeTypeId: false);
      expect(bw.outputAndClear(), bytes(bd));

      bw.write([false, true], writeTypeId: true);
      expect(
          bw.outputAndClear(), [FrameValueType.bool_list_.index, ...bytes(bd)]);
    });

    test("string list", () {
      var bw = getWriter();

      bw.write(["h", "hi"], writeTypeId: false);
      expect(bw.outputAndClear(), [2, 0, 1, 0, 0x68, 2, 0, 0x68, 0x69]);

      bw.write(["h", "hi"], writeTypeId: true);
      expect(bw.outputAndClear(), [
        FrameValueType.string_list_.index, //
        2, 0, 1, 0, 0x68, 2, 0, 0x68, 0x69 //
      ]);
    });

    test("list with null", () {
      var bd = ByteData(21)
        ..setUint16(0, 3, Endian.little)
        ..setUint8(2, FrameValueType.int_.index)
        ..setInt64(3, 123, Endian.little)
        ..setUint8(11, FrameValueType.int_.index)
        ..setInt64(12, 45, Endian.little)
        ..setUint8(20, FrameValueType.null_.index);
      var bw = getWriter();

      bw.write([123, 45, null], writeTypeId: false);
      expect(bw.outputAndClear(), bytes(bd));

      bw.write([123, 45, null], writeTypeId: true);
      expect(bw.outputAndClear(), [FrameValueType.list_.index, ...bytes(bd)]);
    });
  });
}
