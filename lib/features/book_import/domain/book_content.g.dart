// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_content.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookContentAdapter extends TypeAdapter<BookContent> {
  @override
  final int typeId = 2;

  @override
  BookContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookContent(
      bookId: fields[0] as String,
      segments: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, BookContent obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.bookId)
      ..writeByte(1)
      ..write(obj.segments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
