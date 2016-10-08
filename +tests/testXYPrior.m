import YMicroscope.*

xyp = StageXYPrior('com5');

pos = xyp.getPosition();
display(['got xy position ', num2str(pos)])

xyp.setSpeed([0,0]);
display('set speed');

delete(xyp)
display('xy prior stage delete')
