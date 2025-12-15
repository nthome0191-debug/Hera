package print

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func Tree(path, prefix string) error {
	entries, err := os.ReadDir(path)
	if err != nil {
		return err
	}

	var dirs []os.DirEntry
	for _, e := range entries {
		if e.IsDir() && !strings.HasPrefix(e.Name(), ".") {
			dirs = append(dirs, e)
		}
	}

	for i, d := range dirs {
		last := i == len(dirs)-1

		branch := "├── "
		nextPrefix := prefix + "│   "
		if last {
			branch = "└── "
			nextPrefix = prefix + "    "
		}

		fmt.Println(prefix + branch + d.Name())

		if err := Tree(filepath.Join(path, d.Name()), nextPrefix); err != nil {
			return err
		}
	}

	return nil
}
