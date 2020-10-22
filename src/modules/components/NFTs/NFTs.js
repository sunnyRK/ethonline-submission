import BlockUI from 'react-block-ui';
import GoogleLoader from '../../shared/GoogleLoader';
import InterestNFTs from './InterestNFTs/InterestNFTsContainer';
// import ParticipantNFTs from './ParticipantNFTs/ParticipantNFTsContainer';

const NFTs = ({ InterestNFTsList, ParticipantNFTsList, nftsLoading }) => (
  <BlockUI
    tag="div"
    blocking={nftsLoading}
    loader={<GoogleLoader height={50} width={50} />}
    className="block-ui-landing-page"
  >
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
  </BlockUI>
);

export default NFTs;
