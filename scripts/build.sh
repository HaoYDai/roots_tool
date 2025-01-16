#!/bin/bash -e

cmd=${1-build}

into_docker() {
    cd docker
    make run
}

help() {
    echo "RootFS Tool Build Script"
    echo "========================"
    echo
    echo "Description:"
    echo "  Helper script to build, test and deploy the RootFS tool"
    echo
    echo "Usage: $0 <command>"
    echo
    echo "Commands:"
    echo "  build   - Compile and build the RootFS tool"
    echo "  test    - Run the test suite"
    echo "  deploy  - Deploy the built package to target environment"
    echo
    echo "Examples:"
    echo "  $0 build          # Build the project"
    echo "  $0 test          # Run tests"
    echo "  $0 deploy        # Deploy build artifacts"
    exit 1
}

case $cmd in
    "build")
        echo "Building..."
        bash scripts/chroot_build.sh "$2" "$3"
        ;;
    "docker")
        into_docker
        ;;
    "resizeimg")
        truncate -s +1G "$2"
        ;;
    "help"|"--help"|"")
        help
        ;;
    *)
        help
        ;;
esac
