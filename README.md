# Fitness Tracker Smart Contract

A comprehensive blockchain-based fitness tracking system built on the Stacks blockchain using Clarity smart contracts. This contract enables users to track their workout progress, earn fitness badges, and accumulate fitness tokens as rewards.

## Features

### Core Functionality
- **User Profile Management**: Create and manage personalized fitness profiles
- **Workout Tracking**: Record workout sessions with intensity levels and completion rates
- **Achievement System**: Earn fitness badges for reaching milestones
- **Token Rewards**: Generate and track fitness tokens as incentives
- **Admin Controls**: Administrative functions for user data management

### Security Features
- Input validation for all user data
- Access control mechanisms
- Error handling with descriptive error codes
- Protection against duplicate achievements
- Safe mathematical operations

## Contract Structure

### Data Storage
- **User Profiles**: Stores nickname, total points, fitness level, and workout count
- **Workout Tracking**: Records workout sessions with intensity and completion data
- **Fitness Badges**: Manages earned achievements with titles, descriptions, and rewards
- **Fitness Tokens**: Tracks token balances for each user

### Error Codes
- `ERR-ACCESS-DENIED (u1)`: Unauthorized access attempt
- `ERR-INVALID-USER (u2)`: User not found or invalid user operation
- `ERR-INSUFFICIENT-FUNDS (u3)`: Insufficient balance for operation
- `ERR-WORKOUT-NOT-FOUND (u4)`: Requested workout data not found
- `ERR-BADGE-EXISTS (u5)`: Attempting to earn an already-earned badge
- `ERR-BADGE-NOT-FOUND (u6)`: Requested badge not found
- `ERR-INVALID-DATA (u7)`: Invalid input parameters

## Public Functions

### `create-profile`
Creates a new user profile with a unique nickname.
```clarity
(create-profile "FitnessEnthusiast")
```

### `record-workout-session`
Records a workout session with specific parameters.
```clarity
(record-workout-session u1 u75 u100)
```
- `workout-id`: Unique workout identifier (0 < id < 1,000,000)
- `current-intensity`: Workout intensity level (1-99)
- `completion-rate`: Percentage completed (0-100)

### `earn-fitness-badge`
Awards a fitness badge to the user.
```clarity
(earn-fitness-badge u1 "Marathon Runner" "Completed first marathon" u500)
```

### `generate-fitness-tokens`
Generates fitness tokens as rewards.
```clarity
(generate-fitness-tokens u100)
```

### `admin-clear-user-data`
Administrative function to reset user data (admin only).

## Read-Only Functions

### `get-user-profile`
Retrieves user profile information.

### `get-workout-tracking`
Gets specific workout session data.

### `get-user-badges`
Returns list of earned badges (supports up to 5 badges).

### `get-fitness-token-balance`
Checks user's fitness token balance.

## Input Validation

The contract includes comprehensive input validation:
- **Nicknames**: 3-50 characters
- **Workout IDs**: Must be less than 1,000,000
- **Intensity Levels**: 1-99 range
- **Completion Rates**: 0-100 percentage
- **Badge Titles**: 1-100 characters
- **Badge Details**: 1-255 characters

## Usage Example

```clarity
;; 1. Create a user profile
(contract-call? .fitness-tracker create-profile "JohnDoe")

;; 2. Record a workout
(contract-call? .fitness-tracker record-workout-session u1 u80 u95)

;; 3. Earn a badge
(contract-call? .fitness-tracker earn-fitness-badge u1 "First Workout" "Completed your first workout session" u50)

;; 4. Generate fitness tokens
(contract-call? .fitness-tracker generate-fitness-tokens u25)

;; 5. Check profile
(contract-call? .fitness-tracker get-user-profile 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## Security Considerations

- Only the contract admin can reset user data
- All inputs are validated before processing
- No external dependencies or oracle calls
- Immutable achievement records once earned
- Protected against common smart contract vulnerabilities
