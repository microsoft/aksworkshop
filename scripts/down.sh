export RGNAME=akschallenge

echo "This will delete Resource Group $RGNAME and destroy the cluster."
read -p "Are you sure? Type Y to confirm: " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  az group delete --name $RGNAME
else
  echo "\nAborted."
fi

