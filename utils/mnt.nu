#!/usr/bin/env nu
# vim: set ft=nu:

module completes {
    export def main [] { }
    export def cryptsetup-types [] {
        ["luks" "luks2" "_luks" "plain"]
    }
    export def accessible-drives [] {
        ^lsblk --output "NAME" --json | from json
    }
}

use completes

module info {
    export def main [] { }
    export def drive-attributes [] {
        ^lsblk --list-columns --json | from json
    }
    export def --wrapped drive-information [
        ...args: string
        --fields: list<string> = ['NAME' 'MODEL' 'PATH' 'LABEL' 'PARTLABEL' 'UUID' 'PARTUUID']
    ] {
        let di = ^lsblk --output (
            $fields | str join ','
        ) --json ...$args | from json
    }
}

module mnt {
    export def --wrapped main [
        disk: path
        name: string
        ...args: string
        --mount-root: directory
        --lukstype: string@'completes cryptsetup-types'
        --keyparam: record
    ] {
        (
            decrypt
            --lukstype=$lukstype
            --mount-root=$mount_root
            --keyparam=$keyparam
            $disk $name ...$args
        )
    }

    export def --wrapped decrypt [
        disk: string
        name: string
        ...args: string
        --keyparam: record
        --lukstype: string@'completes cryptsetup-types'
    ] {
        # parse out the required parameters and assign sensible defaults if none
        # are given
        let luks_type = $lukstype | default "luks2"

        let keyfile = $keyparam | get "file"
        let cmd = (
            ["cryptsetup" $"--type=($lukstype)" $"--key-file=($keyfile)"]
            | append $args
            | append ["open" $disk $name]
        )
        $cmd | inspect

        ^sudo ...$cmd ...$args open $disk $name
    }

    export def --wrapped recrypt [
        name: string
        ...args: string
    ] {
        ^sudo cryptsetup close ...$args (["/dev" "mapper" $name] | path join)
    }

    export def bind [
        disk: string
        name: string
        --mount-root (-r): directory
        --mapped-name (-n): string
    ] {
        let mount_point = $mount_root | default $"/mnt/($name)"

        ^sudo mount --mkdir $disk $mount_point
    }

    export def unbind [
        ident: string
        --use-mount-root
    ] {
        if $use_mount_root {
            ^sudo umount $ident --recursive
        } else {
            ^sudo umount (["/dev" "mapper" $ident] | path join) --recursive
        }
    }

    export def --wrapped drive [
        disk: string
        name: string
        ...args: string
        --mount-root: directory
        --lukstype: string@'completes cryptsetup-types'
        --keyparam: record
    ] {
        let mount_root = $mount_root | default "/mnt/($name)"
        decrypt $disk $name ...$args --keyparam=$keyparam --lukstype=$lukstype
        if $mount_root != null {
            # if a matching root mounting point is found, then mount the disk
            # accordingly
            bind $disk $name --mount-root=$mount_root
        }
    }

    export def --wrapped detach [
        name: string
        ...args: string
        --use-mount-root
    ] {
        unbind $name --use-mount-root=$use_mount_root
        recrypt $name ...$args
    }

    export def callisto [
        name: string = 'callisto.rsx'
        --cryptsetup-keys-dir (-d): directory = '/etc/cryptsetup-keys.d'
        --mount-map (-m): record<stringdirectory>
    ] {
        let DEVUUID = '2d6b47a9-ade0-4678-bb05-e482d0251457'
        let DEVID = ^blkid --uuid $DEVUUID

        let keyname = [$name 'crypt.key'] | str join "." # callisto.rsx.crypt.key
        let mntname = [$name 'dcrypt'] | str join "." # callisto.rsx.dcrypt
        let keyfile = [$cryptsetup_keys_dir $keyname] | path join # /etc/cryptsetup-keys.d/callisto.rsx.crypt.key

        let vgname = [$name "vg"] | str join "-" # callisto.rsx-vg

        # full drive identifiers are of the form /dev/vgname/partition-lvname,
        # e.g. /dev/callisto.rsx-vg/{name}.callisto.rsx. User is expected to
        # give a mount-map in the form of a record matching partition names to
        # their mount directories. e.g. `{backups: '/mnt/backups'}`

        let driveid = ["/dev" $vgname]

        let keypar = {
            file: $keyfile
        }

        let mount_map = $mount_map | items {|key, mountpoint|
            {([$name $key] | str join "."): $mountpoint}
        }

        $mount_map | items {|key, mount_root|
            (
                drive
                --lukstype='luks2'
                --keyparam=$keypar
                --mount-root=$mount_root
                $DEVID $mntname
            )
        }
    }
}

export use mnt *
