# github-management

A few scripts to help manage things on github.

## Repositories
The `repos.json` file contains a list of repositories that the scripts will act on. For example, when running the `create-labels.sh` script, it will create the labels in ALL the repos listed in `repos.json`.

## Labels
To run any of the label scripts, `cd labels` first.

Labels are defined in `labels.json`, with a name and a color. Note that github matches labels on name, so if you rename a label in `labels.json` without first renaming it in the repositories, you'll end up with two labels, for the old and the new name.

### Create / Update Labels
`./create-labels.sh` will create or update the labels for all repos in `../repos.json`.

### Rename Label
`./rename-label.sh` will rename a label across all repos in `../repos.json`.

### Delete Label
`./delete-label.sh` will delete a label across all repos in `../repos.json`.