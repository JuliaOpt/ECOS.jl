using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["ecos"], :libecos),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/juan-pablo-vielma/ECOSBuilder/releases/download/v0.0.1"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/ECOSBuilder.v1.0.0.aarch64-linux-gnu.tar.gz", "7c81f83d0e0401ac70ccb2cf4957ea85524b74fce8be79f3019febe22d6c526b"),
    Linux(:aarch64, :musl) => ("$bin_prefix/ECOSBuilder.v1.0.0.aarch64-linux-musl.tar.gz", "1b9b5cf0f631e2abb55f3fa6759fb8095723bd6c1664f2300c81f663337de9fa"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/ECOSBuilder.v1.0.0.arm-linux-gnueabihf.tar.gz", "25db5d0a79b409c87e4b25dc8bf78bb2f7877be9979dbd18d452028121e83a5b"),
    Linux(:armv7l, :musl, :eabihf) => ("$bin_prefix/ECOSBuilder.v1.0.0.arm-linux-musleabihf.tar.gz", "8326f851e7cd9520b1cc1c73743de59756228498e3d1d0d4355f28159df3fffb"),
    Linux(:i686, :glibc) => ("$bin_prefix/ECOSBuilder.v1.0.0.i686-linux-gnu.tar.gz", "592b81d704457665063c3ec7cc59dced17e174a16994dbcde3f93de73b935c8b"),
    Linux(:i686, :musl) => ("$bin_prefix/ECOSBuilder.v1.0.0.i686-linux-musl.tar.gz", "24e44322188df1c895582fc85d997b96964d14b917ab01511eedd1306de77f3e"),
    Windows(:i686) => ("$bin_prefix/ECOSBuilder.v1.0.0.i686-w64-mingw32.tar.gz", "785428a4c3efa00ae2738e66e8a56bf52c046123ef7961b598ac2f4c884cfb38"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/ECOSBuilder.v1.0.0.powerpc64le-linux-gnu.tar.gz", "a5ea735be3cc5a15bb34edf3a7dac15374835bc726a1a04fdc63671f89781801"),
    MacOS(:x86_64) => ("$bin_prefix/ECOSBuilder.v1.0.0.x86_64-apple-darwin14.tar.gz", "52ba00b335464eb7b59b6e3782725e773f41fa88015877e485999754f71911d6"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/ECOSBuilder.v1.0.0.x86_64-linux-gnu.tar.gz", "37dba4aaf44cca6f069e6a20714516c23ecb2b1d5f47a73453a3d6fbc69a2439"),
    Linux(:x86_64, :musl) => ("$bin_prefix/ECOSBuilder.v1.0.0.x86_64-linux-musl.tar.gz", "6b3c84259e4a4feb5bb29adf119e58348a2a7d41aaf6a29c0d2e171115547aaf"),
    FreeBSD(:x86_64) => ("$bin_prefix/ECOSBuilder.v1.0.0.x86_64-unknown-freebsd11.1.tar.gz", "5f9e5e66ed92b0f9b0bc8ce781e23acd74403ad5478264668b9b80b4e0b74b50"),
    Windows(:x86_64) => ("$bin_prefix/ECOSBuilder.v1.0.0.x86_64-w64-mingw32.tar.gz", "c7dd7d1e6112ef1d9553a6e21cefbf534bc2a180eaa10e96fd675778b454b966"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)

