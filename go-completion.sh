#!/usr/bin/env bash
# version 1.0.0

_go_completions()
{
    local cur prev words cword
    _init_completion || return

    local commands="build clean doc env bug fix fmt generate get install list mod run test tool version vet help work"

    # Handle main go commands
    if [[ $cword == 1 ]]; then
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        return 0
    fi

    # Handle subcommands
    case "${words[1]}" in
        build|install)
            _go_build_install_completions
            ;;
        run)
            _go_run_completions
            ;;
        test)
            _go_test_completions
            ;;
        get)
            _go_get_completions
            ;;
        list)
            _go_list_completions
            ;;
        mod)
            _go_mod_completions
            ;;
        tool)
            _go_tool_completions
            ;;
        clean)
            _go_clean_completions
            ;;
        fmt)
            _go_fmt_completions
            ;;
        generate)
            _go_generate_completions
            ;;
        vet)
            _go_vet_completions
            ;;
        doc)
            _go_doc_completions
            ;;
        env)
            _go_env_completions
            ;;
        version)
            _go_version_completions
            ;;
        work)
            _go_work_completions
            ;;
        bug)
            _go_bug_completions
            ;;
        fix)
            _go_fix_completions
            ;;
        help)
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

_go_packages_cache=""
_go_packages_checksum=""

_go_packages() {
    local project_root

    project_root=$(pwd)
    while [[ "$project_root" != "/" ]]; do
        if [[ -f "$project_root/go.mod" ]]; then
            break
        fi
        project_root=$(dirname "$project_root")
    done

    if [[ "$project_root" == "/" ]]; then
        project_root=$(pwd)
    fi

    calculate_checksum() {
        find "$project_root" -name '*.go' -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum | awk '{print $1}'
    }

    local current_checksum=$(calculate_checksum)

    if [[ "$current_checksum" != "$_go_packages_checksum" ]] || [[ -z "$_go_packages_cache" ]]; then
        _go_packages_cache=$(cd "$project_root" && go list ./... 2>/dev/null)
        _go_packages_checksum="$current_checksum"
    fi

    echo "$_go_packages_cache"
}

_go_local_packages() {
    local IFS=$'\n'
    local packages=($(compgen -d -- "$cur"))
    for pkg in "${packages[@]}"; do
        if [[ -f "$pkg/go.mod" || -d "$pkg/vendor" ]]; then
            echo "$pkg"
        fi
    done
}

_go_workspace_aware() {
    if [[ -f go.work ]]; then
        echo "-workfile"
    fi
}

_go_build_install_completions()
{
    local workspace_flag="$(_go_workspace_aware)"
    local flags="-a -n -p -race -msan -asan -v -work -x -asmflags -buildmode -compiler -gccgoflags -gcflags -installsuffix -ldflags -linkshared -mod -modcacherw -modfile -overlay -pkgdir -tags -trimpath -toolexec $workspace_flag"
    local buildmodes="archive c-archive c-shared default plugin shared pie"
    
    case "$prev" in
        -o)
            _filedir
            return
            ;;
        -p|-asmflags|-compiler|-gccgoflags|-gcflags|-installsuffix|-ldflags|-pkgdir|-tags|-toolexec)
            return
            ;;
        -buildmode)
            COMPREPLY=($(compgen -W "$buildmodes" -- "$cur"))
            return
            ;;
        -mod)
            COMPREPLY=($(compgen -W "readonly vendor mod" -- "$cur"))
            return
            ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$flags" -- "$cur"))
    else
        COMPREPLY=($(compgen -W "$(_go_local_packages)" -- "$cur"))
        _filedir go
    fi
}

_go_run_completions()
{
    local workspace_flag="$(_go_workspace_aware)"
    local flags="-exec -race -msan -asan -buildvcs -overlay -work $workspace_flag"
    
    case "$prev" in
        -exec)
            COMPREPLY=($(compgen -c -- "$cur"))
            return
            ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$flags" -- "$cur"))
    else
        _filedir go
    fi
}

_go_test_completions()
{
    local workspace_flag="$(_go_workspace_aware)"
    local flags="-args -bench -benchmem -benchtime -count -cover -covermode -coverpkg -cpu -failfast -fuzz -fuzztime -json -list -parallel -run -short -shuffle -timeout -v -vet $workspace_flag"
    
    case "$prev" in
        -exec)
            COMPREPLY=($(compgen -c -- "$cur"))
            return
            ;;
        -covermode)
            COMPREPLY=($(compgen -W "set count atomic" -- "$cur"))
            return
            ;;
        -bench|-benchtime|-count|-coverpkg|-cpu|-run|-timeout|-fuzz|-fuzztime)
            return
            ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$flags" -- "$cur"))
    else
        COMPREPLY=($(compgen -W "$(_go_local_packages)" -- "$cur"))
        _filedir go
    fi
}

_go_get_completions()
{
    local flags="-d -f -t -u -v -fix -insecure"
    
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$flags" -- "$cur"))
    else
        COMPREPLY=($(compgen -W "$(_go_packages)" -- "$cur"))
    fi
}

_go_list_completions()
{
    local workspace_flag="$(_go_workspace_aware)"
    local flags="-e -f -json -m -u -versions -deps -test -export -find -compiled -install -build $workspace_flag"
    
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$flags" -- "$cur"))
    else
        COMPREPLY=($(compgen -W "$(_go_local_packages)" -- "$cur"))
    fi
}

_go_mod_completions()
{
    local subcommands="download edit graph init tidy vendor verify why"
    
    if [[ $cword == 2 ]]; then
        COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
        return 0
    fi

    case "${words[2]}" in
        download)
            COMPREPLY=($(compgen -W "-json -x" -- "$cur"))
            ;;
        edit)
            COMPREPLY=($(compgen -W "-fmt -module -go -print -replace -require -dropreplace -droprequire -json" -- "$cur"))
            ;;
        graph)
            COMPREPLY=($(compgen -W "-go" -- "$cur"))
            ;;
        init)
            # init takes a module path argument, no specific completions
            ;;
        tidy)
            COMPREPLY=($(compgen -W "-v -e -go" -- "$cur"))
            ;;
        vendor)
            COMPREPLY=($(compgen -W "-v -o" -- "$cur"))
            ;;
        verify)
            # verify takes no flags
            ;;
        why)
            COMPREPLY=($(compgen -W "-m -vendor" -- "$cur"))
            ;;
    esac
}

_go_tool_completions()
{
    local tools="addr2line asm cgo compile cover dist fix link nm objdump pack pprof trace vet"
    
    if [[ $cword == 2 ]]; then
        COMPREPLY=($(compgen -W "$tools" -- "$cur"))
        return 0
    fi

    case "${words[2]}" in
        addr2line)
            local addr2line_flags="-e -f -s"
            COMPREPLY=($(compgen -W "$addr2line_flags" -- "$cur"))
            ;;
        asm)
            local asm_flags="-D -I -S -V -debug -dynlink -e -o -shared -trimpath"
            COMPREPLY=($(compgen -W "$asm_flags" -- "$cur"))
            ;;
        cgo)
            local cgo_flags="-debug-define -debug-gcc -dynimport -dynlinker -dynout -dynpackage -exportheader -gccgo -gccgopkgpath -gccgoprefix -godefs -import_runtime_cgo -import_syscall -importpath -objdir -srcdir"
            COMPREPLY=($(compgen -W "$cgo_flags" -- "$cur"))
            ;;
        compile)
            local compile_flags="-D -I -L -N -l -pack -race -msan -asan -shared -dynlink -c -o -trimpath -p -complete -nolocalimports -buildid -race -msan -asan -asmhdr -linkobj -pkg -importcfg -importmap"
            COMPREPLY=($(compgen -W "$compile_flags" -- "$cur"))
            ;;
        cover)
            local cover_flags="-func -html -mode -o -var"
            COMPREPLY=($(compgen -W "$cover_flags" -- "$cur"))
            ;;
        dist)
            local dist_commands="banner bootstrap clean env install list test version"
            if [[ $cword == 3 ]]; then
                COMPREPLY=($(compgen -W "$dist_commands" -- "$cur"))
            else
                case "${words[3]}" in
                    banner|bootstrap|clean|version)
                        COMPREPLY=($(compgen -W "-v" -- "$cur"))
                        ;;
                    env)
                        COMPREPLY=($(compgen -W "-v -p" -- "$cur"))
                        ;;
                    install)
                        COMPREPLY=($(compgen -W "-v" -- "$cur"))
                        _filedir -d
                        ;;
                    list)
                        COMPREPLY=($(compgen -W "-v -json" -- "$cur"))
                        ;;
                    test)
                        COMPREPLY=($(compgen -W "-v -h" -- "$cur"))
                        ;;
                esac
            fi
            ;;
        fix)
            local fix_flags="-diff -force -r"
            COMPREPLY=($(compgen -W "$fix_flags" -- "$cur"))
            ;;
        link)
            local link_flags="-B -D -E -H -I -L -R -T -V -X -buildmode -extld -extldflags -linkmode -linkshared -r -v -w -s -buildid -race -msan -asan -installsuffix -tmpdir -importcfg -k -libgcc -pluginpath"
            COMPREPLY=($(compgen -W "$link_flags" -- "$cur"))
            ;;
        nm)
            local nm_flags="-n -size -sort -type"
            COMPREPLY=($(compgen -W "$nm_flags" -- "$cur"))
            ;;
        objdump)
            local objdump_flags="-s -S"
            COMPREPLY=($(compgen -W "$objdump_flags" -- "$cur"))
            ;;
        pack)
            local pack_flags="c p r t x"
            COMPREPLY=($(compgen -W "$pack_flags" -- "$cur"))
            ;;
        pprof)
            local pprof_flags="-alloc_objects -alloc_space -base -blockprofile -callgrind -disasm -dot -edgefraction -flat -functions -gc -ignore -inuse_objects -inuse_space -lines -nodecount -nodefraction -output -peek -png -proto -sample_index -seconds -svg -tagfocus -tags -text -top -tree -web -weblist -output"
            COMPREPLY=($(compgen -W "$pprof_flags" -- "$cur"))
            ;;
        trace)
            local trace_flags="-http -pprof -t"
            COMPREPLY=($(compgen -W "$trace_flags" -- "$cur"))
            ;;
        vet)
            local vet_flags="-all -asmdecl -assign -atomic -bool -buildtags -cgocall -composites -copylocks -errorsas -framepointer -httpresponse -lostcancel -nilfunc -printf -shift -structtag -tests -unmarshal -unreachable -unsafeptr -unusedresult"
            COMPREPLY=($(compgen -W "$vet_flags" -- "$cur"))
            ;;
    esac
}

_go_clean_completions()
{
    local workspace_flag="$(_go_workspace_aware)"
    local flags="-i -r -n -x -cache -testcache -modcache $workspace_flag"
    
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$flags" -- "$cur"))
    else
        COMPREPLY=($(compgen -W "$(_go_local_packages)" -- "$cur"))
    fi
}

_go_fmt_completions()
{
    local flags="-n -x -mod"
    
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$flags" -- "$cur"))
    else
        COMPREPLY=($(compgen -W "$(_go_local_packages)" -- "$cur"))
        _filedir go
    fi
}

_go_generate_completions()
{
    local flags="-run -n -v -x"
    
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$flags" -- "$cur"))
    else
        COMPREPLY=($(compgen -W "$(_go_local_packages)" -- "$cur"))
        _filedir go
    fi
}

_go_vet_completions()
{
    local workspace_flag="$(_go_workspace_aware)"
    local flags="-n -x -vettool $workspace_flag"
    
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$flags" -- "$cur"))
    else
        COMPREPLY=($(compgen -W "$(_go_local_packages)" -- "$cur"))
        _filedir go
    fi
}

_go_doc_completions()
{
    local flags="-all -c -cmd -short -src -u"
    
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$flags" -- "$cur"))
    else
        COMPREPLY=($(compgen -W "$(_go_packages)" -- "$cur"))
    fi
}

_go_env_completions()
{
    local env_vars="GOARCH GOOS GOPATH GOROOT GO111MODULE GOCACHE GOENV GOMODCACHE GOTMPDIR GOVERSION GCCGO GOEXE GOGCCFLAGS GOHOSTARCH GOHOSTOS GOINSECURE GONOPROXY GONOSUMDB GOPRIVATE GOPROXY GOROOT_FINAL GOSUMDB GOTOOLDIR GOWORK"
    if [[ $cword == 2 ]]; then
        COMPREPLY=($(compgen -W "$env_vars -json -u -w" -- "$cur"))
    else
        COMPREPLY=($(compgen -W "$env_vars" -- "$cur"))
    fi
}

_go_version_completions()
{
    local flags="-m -v"
    COMPREPLY=($(compgen -W "$flags" -- "$cur"))
}

_go_work_completions()
{
    local subcommands="edit init sync use"
    
    if [[ $cword == 2 ]]; then
        COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
        return 0
    fi

    case "${words[2]}" in
        edit)
            COMPREPLY=($(compgen -W "-go -print -replace -use" -- "$cur"))
            ;;
        init)
            _filedir -d
            ;;
        sync)
            # sync takes no specific flags
            ;;
        use)
            COMPREPLY=($(compgen -W "-r" -- "$cur"))
            _filedir -d
            ;;
    esac
}

_go_bug_completions()
{
    :  # 'go bug' doesn't take any flags
}

_go_fix_completions()
{
    local flags="-diff -force"
    
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$flags" -- "$cur"))
    else
        COMPREPLY=($(compgen -W "$(_go_local_packages)" -- "$cur"))
        _filedir go
    fi
}

complete -F _go_completions go