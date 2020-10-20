import NFT1 from '../../../../assets/images/nft1.jpg';
import NFT2 from '../../../../assets/images/nft2.jpg';
import NFT3 from '../../../../assets/images/nft3.jpg';
// import NFT4 from '../../../../assets/images/nft4.webp';
import NFT5 from '../../../../assets/images/nft5.jpg';

const InterestNFTsList = [
  {
    key: 1,
    value: 'NFT1',
    image: NFT1,
    podName: 'Pod Name',
    price: '$20',
  },
  {
    key: 2,
    value: 'NFT2',
    image: NFT2,
    podName: 'Pod Name',
    price: '$20',
  },
  {
    key: 3,
    value: 'NFT3',
    image: NFT3,
    podName: 'Pod Name',
    price: '$20',
  },
  {
    key: 4,
    value: 'NFT4',
    image: NFT1,
    podName: 'Pod Name',
    price: '$20',
  },
  {
    key: 5,
    value: 'NFT5',
    image: NFT2,
    podName: 'Pod Name',
    price: '$20',
  },
];

const InterestNFTs = () => (
  <div className="interest-nfts-container">
    <h3 className="heading">Interest NFTs</h3>
    <div className="interest-nfts">
      {InterestNFTsList.map((nft) => (
        <div className="nft-container">
          <img src={nft.image} className="nft" alt="nft" />
          <div className="nft-info">
            <div className="pod-name">{nft.podName}</div>
            <div className="price">{nft.price}</div>
          </div>
        </div>
      ))}
    </div>
  </div>
);

export default InterestNFTs;
