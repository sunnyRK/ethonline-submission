import { Button } from '@material-ui/core';

const InterestNFTs = ({ heading, nftsList, onRedeemClick }) => (
  <div className="interest-nfts-container">
    <h3 className="heading">{heading || 'NFTs'}</h3>
    <div className="interest-nfts">
      {console.log('nftsList=====', nftsList)}
      {/* {console.log('Object.keys(nftsList).length=====', Object.keys(nftsList).length)} */}
      {nftsList.length > 0 ? nftsList.map((nft) => (
        <div className="nft-container">
          <div className="nft">
            <div className="nft-info">
              <div className="price">{nft.price}</div>
              <div className="pod-name">{nft.tokenId}</div>
            </div>
          </div>
          <div className="redeem-button-wrapper">
            <Button
              className="redeem-button"
              disableRipple
              disableElevation
              // variant="contained"
              onClick={() => onRedeemClick(nft.tokenId)}
            >
              {console.log('nft=====', nft)}
              {nft.isDead ? 'Already Redeemed' : 'Redeem'}
            </Button>
          </div>
        </div>
      )) : <div className="no-data">No NFTs</div>}
    </div>
  </div>
);

export default InterestNFTs;
