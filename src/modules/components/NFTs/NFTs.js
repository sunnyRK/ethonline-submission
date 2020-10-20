import InterestNFTs from './InterestNFTs/InterestNFTsContainer';
import ParticipantNFTs from './ParticipantNFTs/ParticipantNFTsContainer';

const NFTsContainer = () => (
  <div className="nfts-container">
    <InterestNFTs />
    <ParticipantNFTs />
  </div>
);

export default NFTsContainer;
