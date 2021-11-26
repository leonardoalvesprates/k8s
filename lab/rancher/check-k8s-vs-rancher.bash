#!/usr/bin/env bash
set -e

branch="$(curl -sL https://api.github.com/repos/rancher/kontainer-driver-metadata/branches | jq -r '.[].name' | grep 'release-')"

PS3="Choose a branch to use: "
COLUMNS=20
select v in ${branch} Exit; do
	case $v in
		Exit)
			echo "Exiting, did nothing."
			break
			;;
		*)
		  url="https://raw.githubusercontent.com/rancher/kontainer-driver-metadata/$v/data/data.json"
		  curl -sL "$url" | jq -r '.K8sVersionRKESystemImages | keys[]' | sort -u -V
		  break
      ;;
  esac
done
