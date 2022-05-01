# Frenchie Friends Club Smart-Contract DOC

## Constructor
Set Collection :
1. Name
2. symbol
3. Total supply
4. whiteList supply

## Variables
1. PublicSalePrice == unsigned int- the price of public sale
2.  WhiteListSalePrice == unsigned int- the price of WhiteList sale
3.  MaxTotalMintAmount == unsigned int - Maximum a Wallet can Mint in public and WhiteList Mint
4.  MaxWhiteListMintAmount == unsigned int - Maximum a Wallet can Mint in WhiteList Mint
5.  MaxPublicMintAmount == unsigned int - Maximum a Wallet can Mint in Public Mint
6.  TotalSupply == unsigned int - Max FFC NFT
7.  TotalWhiteListSupply == Max FFC NFT can Mint in WhiteList Mint
8.  Supply == NFTs Mint until now
9.  WhiteListMinted == Mapping == List of WhiteList wallet Minted
10.  PublicMinted == Mapping - List of Public wallet Minted
11.  WhiteListSaleStatus == Boolean - WhiteList Mint Status
12.  PublicSaleStatus == Boolean - Public Mint Status
13.  WhiteListRoot == bytes32 - Merkle Root 
14.  IsReveal == boolean - Reveal status
15.  


## Modifier

1. callerIsUser == user cant be contract

## Functins 
### 1.Mint
 1. input == Unsigned int - Amount
2. output == transaction resualt

##### requires for Users/owner
 1. Public Mint should be enable
 2. Amount should not exeed total supply
 3. Amount should be bigger than 0 

##### requires for users 
1. amount should not exeed MaxTotalSupply
2. amount should not exeed MaxPulicMintAmount
3. sended ether should be bigger or equal than amount*price 

### 2.WhiteListMint
 1. input == Unsigned int - Amount // bytes32[] - merkle proof
2. output == transaction resualt

##### requires for Users/owner
 1. whitelist Mint should be enable
 2. user should be in whiteList
 3. Amount should be bigger than 0 
4. amount should not exeed MaxTotalSupply
5. amount should not exeed MaxWhiteListMintAmount
6. sended ether should be bigger or equal than amount*price 

-----------------------
-----------------
## OnlyOwners Functions 
-------------
----------

### 3.ToggleWhitelistSaleStatus
change whiteList status

### 4.TogglePublicSaleStatus
change Public Mint status
### 5.setMerkleRoot
input = bytes32 - root of mekle tree
### 6.withdraw
withdraw contract balance to owner wallet
### 7.SetBaseURI
input = string - Base URI with "IPFS://< CID >"

### 8.SetUnRevealURI
input = string - Base unreveal URI with "IPFS://< CID >"

## Errors List

    error DirectMintFromContractNotAllowed();
    error ZeroAddressCantMint();
    error PublicSaleInactive();
    error WhiteListSaleInactive();
    error ExceedWhiteListMintAmount();
    error ExceedMaxPublicMintAmount();
    error InsufficientETHSent();
    error ExceedsAllocatedForWhiteListSale();
    error NotOnWhitelist();
    error ExceedsMaxSupply();
    error WithdrawalFailed();
    error ExceedTotalMintAmount();
    error AmountCantBeZero();
