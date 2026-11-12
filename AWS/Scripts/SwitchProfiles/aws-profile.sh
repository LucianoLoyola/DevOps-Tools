#!/usr/bin/env zsh
################################################################################
# aws-profile — switch AWS profile in the current shell.
#
# Usage:
#   aws-profile              -> show current profile
#   aws-profile <TAB>        -> list every profile in ~/.aws/config
#   aws-profile intel<TAB>   -> complete partial name
#   aws-profile <name>       -> export AWS_PROFILE=<name>
#   aws-profile --unset      -> clear AWS_PROFILE
#
# The tab-completion lives in completions/_aws-profile (autoloaded via
# fpath) so it survives every compinit call.
################################################################################

aws-profile() {
  case "$1" in
    "" )
      echo "AWS_PROFILE=${AWS_PROFILE:-<none>}"
      return 0
      ;;
    --unset|-u )
      unset AWS_PROFILE
      echo "AWS_PROFILE cleared"
      return 0
      ;;
  esac
  export AWS_PROFILE="$1"
  echo "AWS_PROFILE=$AWS_PROFILE"
}
