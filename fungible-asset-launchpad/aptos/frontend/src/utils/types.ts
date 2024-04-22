export type FungibleAssetMetadata = {
  /// Name of the fungible metadata, i.e., "USDT".
  name: string;
  /// Symbol of the fungible metadata, usually a shorter version of the name.
  /// For example, Singapore Dollar is SGD.
  symbol: string;
  /// Number of decimals used for display purposes.
  /// For example, if `decimals` equals `2`, a balance of `505` coins should
  /// be displayed to a user as `5.05` (`505 / 10 ** 2`).
  decimals: number;
};
