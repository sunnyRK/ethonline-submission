import InterestNFTs from './InterestNFTs/InterestNFTsContainer';
// import ParticipantNFTs from './ParticipantNFTs/ParticipantNFTsContainer';

const NFTs = ({ InterestNFTsList, ParticipantNFTsList }) => (
  <div className="nfts-container">
    <InterestNFTs
      heading="Winning NFTs"
      nftsList={InterestNFTsList}
    />
    <InterestNFTs
      heading="Participant NFTs"
      nftsList={ParticipantNFTsList}
    />
  </div>
);

export default NFTs;
