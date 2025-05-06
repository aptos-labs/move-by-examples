export type Aptogotchi = {
  name: string;
  address: string;
};

export type AptogotchiTraits = {
  body: number;
  ear: number;
  face: number;
};

export type Listing = {
  listing_object_address: string;
  price: number;
  seller_address: string;
};

export type AptogotchiWithTraits = Aptogotchi & AptogotchiTraits;
export type ListedAptogotchiWithTraits = Aptogotchi &
  AptogotchiTraits &
  Listing;
