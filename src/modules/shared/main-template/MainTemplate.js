import React from 'react';
import {
  Container, List, Header,
  Grid, Segment,
} from 'semantic-ui-react';
import { withRouter } from 'next/router';

const menuItems = [
  {
    key: 0,
    value: 'Dashboard',
    path: '',
  },
  {
    key: 1,
    value: 'NFTs',
    path: 'nfts',
  },
  {
    key: 2,
    value: 'Piggy Bank',
    path: 'piggy-bank',
  },
];

const MainTemplate = ({
  children, metamaskAddress, router,
  selectedMenuItem, handleState,
}) => (
  <div className="main-template">
    <div className="main-header">
      <div className="app-name">InstCrypt</div>
      <div className="header-menu-items">
        {
          menuItems.map((menuItem, index) => (
            <div
              role="presentation"
              onClick={() => {
                router.push(`/${menuItem.path}`);
                handleState({ selectedMenuItem: index });
              }}
              className={`menu-items ${selectedMenuItem === index && 'active'}`}
            >
              {menuItem.value}
            </div>
          ))
        }
      </div>
      <div className="metamask-address">{metamaskAddress}</div>
    </div>
    <div className="main-content">
      {children}
    </div>
    <div className="main-footer">
      <Segment inverted vertical className="app-footer">
        <Container>
          <Grid divided inverted stackable>
            <Grid.Row>
              <Grid.Column width={4}>
                <Header inverted as="h4" content="About Us" />
                <List link inverted>
                  <List.Item as="a">Sunny Radadiya <a href="https://www.linkedin.com/in/sunnyradadiya/" target="_blank">LinkedIn</a></List.Item>
                  <List.Item as="a">Rajat Beladiya <a href="https://www.linkedin.com/in/rajat-b-17695a116/" target="_blank">LinkedIn</a></List.Item>
                </List>
              </Grid.Column>
              <Grid.Column width={4}>
                <Header inverted as="h4" content="Contact Us" />
                <List link inverted>
                  <List.Item as="a" href="mailto:radadiyasunny970@gmail.com">radadiyasunny970@gmail.com</List.Item>
                  <List.Item as="a" href="mailto:rajatbeladiya7@gmail.com">rajatbeladiya7@gmail.com</List.Item>
                </List>
              </Grid.Column>
            </Grid.Row>
          </Grid>
        </Container>
      </Segment>
    </div>
  </div>
);

export default withRouter(MainTemplate);
