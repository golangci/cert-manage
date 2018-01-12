package test

import (
	"fmt"
	"testing"
)

func TestUbuntu(t *testing.T) {
	total, after := "148", "5" // os specific values, will change

	img := Dockerfile("envs/ubuntu")
	img.CertManage("list", "-count", "|", "grep", total)
	// Backup
	img.CertManage("backup")
	img.RunSplit(fmt.Sprintf("ls -1 /usr/share/ca-certificates/* | wc -l | grep %s", total))
	img.RunSplit(fmt.Sprintf("ls -1 /usr/share/ca-certificates.backup/* | wc -l | grep %s", total))
	// Whitelist
	img.CertManage("whitelist", "-file", "/whitelist.json")
	img.CertManage("list", "-count", "|", "grep", after)
	// Restore
	img.CertManage("restore")
	img.CertManage("list", "-count", "|", "grep", total)
	img.SuccessT(t)
}
