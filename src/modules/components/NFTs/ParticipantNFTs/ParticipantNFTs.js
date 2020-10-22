// import NFT6 from '../../../../assets/images/nft6.jpg';
import NFT7 from '../../../../assets/images/nft7.png';
import NFT8 from '../../../../assets/images/nft8.jpg';
import NFT9 from '../../../../assets/images/nft9.jpg';
import NFT10 from '../../../../assets/images/nft10.png';

const ParticipantNFTsList = [
  {
    key: 1,
    value: 'NFT1',
    image: NFT10,
    podName: 'Pod Name',
    price: '$20',
  },
  {
    key: 2,
    value: 'NFT2',
    image: NFT7,
    podName: 'Pod Name',
    price: '$20',
  },
  {
    key: 3,
    value: 'NFT3',
    image: NFT8,
    podName: 'Pod Name',
    price: '$20',
  },
  {
    key: 4,
    value: 'NFT4',
    image: NFT9,
    podName: 'Pod Name',
    price: '$20',
  },
  {
    key: 5,
    value: 'NFT5',
    image: NFT10,
    podName: 'Pod Name',
    price: '$20',
  },
];

const ParticipantNFTs = () => (
  <div className="participant-nfts-container">
    <h3 className="heading">Participant NFTs</h3>
    <div className="participant-nfts">
      {ParticipantNFTsList.map((nft) => (
        <div className="nft-container">
          {/* <img src={nft.image} className="nft" alt="nft" /> */}
          <div className="nft-info">
            <div className="pod-name">{nft.podName}</div>
            <div className="price">{nft.price}</div>
          </div>
        </div>
      ))}
    </div>
  </div>
);

export default ParticipantNFTs;
