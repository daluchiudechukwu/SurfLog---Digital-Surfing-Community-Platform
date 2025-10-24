# SurfLog - Digital Surfing Community Platform

A blockchain-based platform built on Stacks that enables surfers to log sessions, share surf spots, write reviews, and earn rewards through the SurfLog Wave Token (SWT).

## Overview

SurfLog creates a decentralized surfing community where participants are rewarded for contributing valuable surf data. The platform incentivizes session logging, spot discovery, and community engagement through a token-based reward system.

## Features

### 🏄 Core Functionality

- **Surfer Profiles**: Create and manage your surfing identity with customizable usernames and surf styles
- **Surf Spot Database**: Community-sourced database of surf breaks with detailed conditions
- **Session Logging**: Record your surf sessions with wave data, conditions, and personal notes
- **Spot Reviews**: Rate and review surf spots with crowd level indicators
- **Milestone Achievements**: Unlock achievements and earn bonus rewards

### 💰 Token Economy

**SurfLog Wave Token (SWT)**
- Symbol: SWT
- Decimals: 6
- Max Supply: 44,000 tokens
- Reward Structure:
  - Session Log: 2.0 SWT
  - Epic Session Bonus: +1.5 SWT
  - New Spot Submission: 2.6 SWT
  - Milestone Achievement: 9.4 SWT

## Smart Contract Functions

### Public Functions

#### Profile Management

**`update-username`**
```clarity
(update-username (new-username (string-ascii 24)))
```
Set or update your display username.

**`update-surf-style`**
```clarity
(update-surf-style (new-surf-style (string-ascii 12)))
```
Update your surfing style preference (longboard, shortboard, bodyboard, sup, beginner).

#### Surf Spots

**`add-surf-spot`**
```clarity
(add-surf-spot 
  (spot-name (string-ascii 34))
  (location (string-ascii 24))
  (break-type (string-ascii 12))
  (wave-direction (string-ascii 8))
  (skill-level (string-ascii 12))
  (best-conditions (string-ascii 20)))
```
Submit a new surf spot to the platform. Rewards: 2.6 SWT.

**Parameters:**
- `spot-name`: Name of the surf break
- `location`: Geographic location
- `break-type`: beach, reef, point, or rivermouth
- `wave-direction`: left, right, or both
- `skill-level`: beginner, intermediate, or advanced
- `best-conditions`: Optimal swell/wind conditions

#### Session Logging

**`log-session`**
```clarity
(log-session
  (spot-id uint)
  (wave-height uint)
  (wind-conditions (string-ascii 8))
  (session-duration uint)
  (waves-caught uint)
  (session-notes (string-ascii 100))
  (epic-session bool))
```
Record a surf session at a registered spot. Rewards: 2.0-3.5 SWT.

**Parameters:**
- `spot-id`: ID of the surf spot
- `wave-height`: Wave height in centimeters
- `wind-conditions`: offshore, onshore, or calm
- `session-duration`: Length of session in minutes
- `waves-caught`: Number of waves successfully ridden
- `session-notes`: Personal notes about the session
- `epic-session`: Flag for exceptional sessions (bonus reward)

#### Reviews & Community

**`write-review`**
```clarity
(write-review
  (spot-id uint)
  (rating uint)
  (review-text (string-ascii 140))
  (crowd-level (string-ascii 8)))
```
Write a review for a surf spot (one review per user per spot).

**`vote-stoked`**
```clarity
(vote-stoked (spot-id uint) (reviewer principal))
```
Upvote a helpful review (cannot vote for your own reviews).

#### Achievements

**`claim-milestone`**
```clarity
(claim-milestone (milestone (string-ascii 12)))
```
Claim achievement rewards when requirements are met.

**Available Milestones:**
- `surfer-45`: Log 45 surf sessions (9.4 SWT)
- `explorer-8`: Share 8 surf spots (9.4 SWT)

### Read-Only Functions

**`get-surfer-profile`**
```clarity
(get-surfer-profile (surfer principal))
```
Retrieve a surfer's profile data including stats and achievements.

**`get-surf-spot`**
```clarity
(get-surf-spot (spot-id uint))
```
Get details about a specific surf spot.

**`get-surf-session`**
```clarity
(get-surf-session (session-id uint))
```
Retrieve information about a logged session.

**`get-spot-review`**
```clarity
(get-spot-review (spot-id uint) (reviewer principal))
```
Read a specific user's review of a surf spot.

**`get-milestone`**
```clarity
(get-milestone (surfer principal) (milestone (string-ascii 12)))
```
Check if a user has claimed a specific milestone.

**Token Functions:**
- `get-name`: Returns token name
- `get-symbol`: Returns SWT
- `get-decimals`: Returns 6
- `get-balance`: Check SWT balance for any address

## Data Structures

### Surfer Profile
```clarity
{
  username: (string-ascii 24),
  surf-style: (string-ascii 12),
  sessions-logged: uint,
  spots-shared: uint,
  waves-ridden: uint,
  surfer-level: uint,
  join-date: uint
}
```

### Surf Spot
```clarity
{
  spot-name: (string-ascii 34),
  location: (string-ascii 24),
  break-type: (string-ascii 12),
  wave-direction: (string-ascii 8),
  skill-level: (string-ascii 12),
  best-conditions: (string-ascii 20),
  submitter: principal,
  session-count: uint,
  average-rating: uint
}
```

### Surf Session
```clarity
{
  spot-id: uint,
  surfer: principal,
  wave-height: uint,
  wind-conditions: (string-ascii 8),
  session-duration: uint,
  waves-caught: uint,
  session-notes: (string-ascii 100),
  session-date: uint,
  epic-session: bool
}
```

## Error Codes

- `u100`: Owner-only operation
- `u101`: Resource not found
- `u102`: Resource already exists
- `u103`: Unauthorized action
- `u104`: Invalid input parameters

## Security Features

- Owner-controlled contract deployment
- Input validation on all public functions
- One review per user per spot
- Self-voting prevention on reviews
- Milestone claim validation
- Token supply cap enforcement
- Profile auto-creation on first interaction

## Use Cases

1. **Surf Tourism**: Discover new spots with community ratings and conditions
2. **Session Tracking**: Build your personal surf log with detailed statistics
3. **Community Building**: Connect with local surfers and share knowledge
4. **Gamification**: Compete for milestones and rewards
5. **Data Collection**: Aggregate surf conditions over time
6. **Reward Distribution**: Earn tokens for contributing valuable data

## Future Enhancements

Potential additions to consider:
- Token transfer functionality
- Advanced milestone tiers
- Seasonal leaderboards
- Photo/video uploads (IPFS integration)
- Weather data oracle integration
- Spot forecasting based on historical data
- Social features (follow surfers, comment on sessions)
- NFT badges for rare achievements

## Getting Started

1. Deploy the contract to Stacks blockchain
2. Create your surfer profile with `update-username`
3. Add surf spots you know with `add-surf-spot`
4. Log your sessions with `log-session`
5. Write reviews and earn tokens
6. Track your progress and claim milestones

## License

This smart contract is provided as-is for community use.

## Contributing

Contributions, suggestions, and feedback are welcome to improve the SurfLog platform.

---

**Built with ❤️ for the global surfing community**

*Ride waves, earn rewards, build community* 🏄‍♂️🌊
