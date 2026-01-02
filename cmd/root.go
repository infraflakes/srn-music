package cmd

import (
	"github.com/infraflakes/srn-music/pkg"
	"github.com/spf13/cobra"
)

var RootCmd = &cobra.Command{
	Use:   "smusic",
	Short: "Music utilities for conversion and download",
}

func Execute() error {
	return RootCmd.Execute()
}

func init() {
	RootCmd.AddCommand(pkg.ConvertCmd)
	RootCmd.AddCommand(pkg.YTMusicDownloadCmd)
}
