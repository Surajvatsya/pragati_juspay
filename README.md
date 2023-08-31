# Pragati

## Setup

# Frontend
1. cd Frontend
2. nix develop

Continue with Build steps. 

### Build
1. npm i (to install the node_modules)
2. npm run start

### Backend

#### Setup and Build
1. Install nix and enable nix flakes.
2. cd Backend
3. nix build - for building the code.
4. nix run - for running the code.

### Start elastic search on default port (9200)
1. nix run .#elastic
