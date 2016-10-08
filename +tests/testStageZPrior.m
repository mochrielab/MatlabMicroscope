import YMicroscope.*

zstage = StageZPrior.coarsescan;
display('Zstage created');

zstage.setPosition(3.5);
display('z position set')

z = zstage.getPosition();
display(['z position is ',num2str(z)]);

