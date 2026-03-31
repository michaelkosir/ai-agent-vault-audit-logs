#! /usr/bin/env bash

export VAULT_ADDR=http://localhost:8200

vault operator init -format=json -key-shares=1 -key-threshold=1 > init.json

vault operator unseal $(jq -r ".unseal_keys_b64[0]" init.json)

vault login $(jq -r ".root_token" init.json)

vault audit enable socket address="vector:9000"

vault auth enable userpass
vault secrets enable -version=2 kv



users=("michael" "rosemary" "richard" "sam" "kerim" "nic" "rob" "chris")
for user in "${users[@]}"; do

    vault login $(jq -r ".root_token" init.json)

    echo "########"
    echo "Creating user: $user"
    echo "########"

    vault policy write $user - <<EOF
path "kv/+/$user" {
  capabilities = ["create", "read", "update", "delete", "list", "patch"]
}
EOF

    vault write auth/userpass/users/$user password=$user policies=$user
    vault kv put kv/$user api_key=$(uuidgen)

    vault login -method=userpass username=$user password=$user
    vault kv get kv/$user
    vault kv put kv/$user api_key=$(uuidgen)

    if [ "$user" == "sam" ]; then
        echo "########"
        echo "Failed access attempts for user: $user"
        echo "########"
        for u in "${users[@]}"; do
            vault kv list kv/
            vault kv get kv/$u
        done
    fi

    if [ "$user" == "sam" ]; then
        echo "########"
        echo "Failed login attempts for user: $user"
        echo "########"
        for u in "${users[@]}"; do
            vault login -no-store -method=userpass username=$u password=12345
        done
    fi

done
