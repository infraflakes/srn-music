package pkg

import (
	"github.com/infraflakes/srn-libs/cli"
	"github.com/infraflakes/srn-libs/exec"
	"github.com/infraflakes/srn-libs/utils"
	"github.com/spf13/cobra"
)

var YTMusicDownloadCmd = cli.NewCommand(
	"download [youtube-url]",
	"Download audio from YouTube using yt-dlp",
	cobra.ExactArgs(1),
	func(cmd *cobra.Command, args []string) {
		youtubeURL := args[0]
		utils.CheckErr(exec.ExecuteCommand(
			"yt-dlp",
			"--extract-audio",
			"--embed-thumbnail",
			"--add-metadata",
			"-o", "%(title)s.%(ext)s",
			youtubeURL,
		))
	},
)
