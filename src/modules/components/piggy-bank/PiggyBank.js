import { Button } from '@material-ui/core';
import BlockUI from 'react-block-ui';
import GoogleLoader from '../../shared/GoogleLoader';

const PiggyBank = ({ onClaimClick, totalEarnedPiggy, totalSupply, claimablePiggy, loading }) => {
  const PiggyBankList = [
    {
      key: 'total-earbed-piggy',
      text: 'Total Earned Piggy',
      value: 1200,
    },
    {
      key: 'claimable-piggy',
      text: 'Claimable Piggy',
      value: claimablePiggy,
    },
    {
      key: 'total-supply',
      text: 'Total Supply',
      value: totalSupply,
    },
  ];
  return (
    <BlockUI
      tag="div"
      blocking={loading}
      loader={<GoogleLoader height={50} width={50} />}
      className="block-ui-landing-page"
    >
      <div className="piggy-bank-container">
        <div className="piggy-bank-content">
          <div className="piggy-bank">
            {PiggyBankList.map((listItem) => (
              <div className="piggy-list-item" key={listItem.key}>
                <h3 className="title-value">{listItem.value}</h3>
                <h3 className="title">{listItem.text}</h3>
                {listItem.key === 'claimable-piggy' && (
                  <div className="claim-button-wrapper">
                    <Button
                      className="claim-button"
                      disableRipple
                      disableElevation
                      // variant="contained"
                      onClick={() => onClaimClick()}
                    >
                      Claim
                    </Button>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      </div>
    </BlockUI>
  )
};

export default PiggyBank;
