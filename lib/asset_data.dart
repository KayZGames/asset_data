import 'dart:convert' as convert;

/// Annotation for assets which will be embedded. Path needs to be of the format
/// `asset:library/path/to/asset`
class Asset {
  final String path;

  const Asset(this.path);
}

/// An asset containing plain text.
class TextAsset extends FileAsset {
  /// Create instances with a [asset] parameter of this format:
  ///
  ///     _variablename$asset,
  ///
  /// where variablename is the name of the variable this object gets assigned
  /// to. The asset_builder will generate the parameter-object.
  const TextAsset(AssetData asset) : super(asset);
}

/// An asset containing binary data, encoded via base64 encoding.
///
/// The decoded data can be accessed via [decode()].
class BinaryAsset extends FileAsset {
  /// Create instances with a [asset] parameter of this format:
  ///
  ///     _variablename$asset
  ///
  /// where variablename is the name of the variable this object gets assigned
  /// to. The asset_builder will generate the parameter-object.
  const BinaryAsset(AssetData asset) : super(asset);

  /// The base64-encoded data as a string.
  String get encoded => _asset.content;

  /// Return an iterable of the decoded binary data.
  Iterable<int> decode() => convert.base64Decode(encoded);
}

/// An asset containing Json data. The data can be parsed via [json()].
class JsonAsset extends TextAsset {
  const JsonAsset(AssetData asset) : super(asset);

  /// Parse and return the json object.
  dynamic json() => convert.json.decode(content);
}

/// Describes the packed asset.
class AssetData {
  /// The id of the asset
  final String id;

  /// The content of the asset
  final String content;
  const AssetData(this.id, this.content);
}

abstract class FileAsset {
  final AssetData _asset;
  const FileAsset(this._asset);
  String get assetId => _asset.id;
  String get content => _asset.content;
}

/// An asset containing all files selected by the glob in [@Asset].
/// Limited to the current package.
class DirAsset<S extends FileAsset, T extends Enum> {
  final Map<T, S> _fileAssets;

  /// Create instances with a [fileAssets] parameter of this format:
  ///
  ///     _variablename$asset
  ///
  /// where variablename is the name of the variable this object gets assigned
  /// to. The asset_builder will generate the parameter-object and the enum [T}.
  const DirAsset(Map<T, S> fileAssets) : _fileAssets = fileAssets;
  S operator [](T assetKey) {
    if (_fileAssets.containsKey(assetKey)) {
      return _fileAssets[assetKey]!;
    }
    throw ArgumentError.value(
        assetKey, 'assetKey', 'No asset $assetKey exists');
  }
}
