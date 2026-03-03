# Host System Specifications

This project has been tested on the following configurations:

## Tested Platforms

### Apple Silicon (ARM64)
- **Chip**: Apple M1 / M2 / M3 / M4
- **Architecture**: ARM64
- **macOS**: Sequoia 15.x or later recommended
- **Memory**: 8GB minimum, 16GB+ recommended

### Intel Macs (AMD64)
- **Architecture**: x86_64
- **macOS**: Ventura 13.x or later recommended
- **Memory**: 8GB minimum, 16GB+ recommended

## Checking Your System

To determine your system specs, run:

```bash
# Architecture
uname -m

# macOS version
sw_vers

# Hardware overview
system_profiler SPHardwareDataType
```

## Notes

- The container image is automatically built for your architecture (ARM64 or AMD64)
- Podman machine requires hardware virtualization support
- At least 2GB of free disk space is recommended for the container image
