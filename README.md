# PhotoBooth

Simple PhotoBooth app for iOS. Take photos with the camera, add themes and clips, print them to a rad printer.

## Development

When developing you likely want to save paper and ink. To do this, create a virtual PDF printer that runs on your Mac and serve it as an AirPrint printer.

### Install a local PDFWriter

https://github.com/rodyager/RWTS-PDFwriter

### Share the printer

```bash
lpadmin -p PDFwriter -o printer-is-shared=true
```

### Mirror that printer

```bash
dns-sd -R "PDFwriter AirPrint" _ipp._tcp,_universal local. 631 txtvers=1 qtotal=1 rp=printers/PDFwriter ty=RWTS\ PDFwriter adminurl=none note= priority=0 product=\(RWTS\ PDFwriter\ v1.0\) pdl=application/octet-stream,application/pdf,application/postscript,image/jpeg,image/png,image/pwg-raster,image/urf  TLS=1.2 Color=T Copies=T printer-state=3 printer-type=0xF04E URF=none
```

When you print the documents will show up at 

`"/Users/Shared/PDFwriter/anonymous users"`


# TODO

- [ ] Describe the setup
- [x] Use a fake image in the simulator
- [ ] GPUImage filters
- [ ] Filter switching (tap)
- [ ] Clip masks
- [ ] Themes on the printout
- [ ] Better top/bottom constraints
- [ ] DWS Design