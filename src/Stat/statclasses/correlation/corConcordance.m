function Correlation = corConcordance(obj,crObj)

if nargin<2

  crObj = obj.Object.Correlation;

elseif nargin == 2

  obj.Object.Correlation = crObj;

end

[comb, lbIdx, sig] = qmrstat.corInit(crObj);
crObj = crObj.setSignificanceLevel(sig);

szcomb = size(comb);

Correlation = repmat(struct(), [lbIdx szcomb(1)]);
for kk = 1:szcomb(1) % Loop over correlation matrix combinations
for zz = 1:lbIdx % Loope over labeled mask indexes (if available)

% Combine pairs
curObj = [crObj(1,comb(kk,1)),crObj(1,comb(kk,2))];

if lbIdx >1

    % If mask is labeled, masking will be done by the corresponding
    % index, if index is passed as the third parameter.
    [VecX,VecY,XLabel,YLabel,sig] = qmrstat.getBivarCorInputs(obj,curObj,curObj(1).LabelIdx(zz));

else
    % If mask is binary, then index won't be passed.
    [VecX,VecY,XLabel,YLabel,sig] = qmrstat.getBivarCorInputs(obj,curObj);

end

if strcmp(crObj(1).FigureOption,'osd')

  [rC,biasFactorC,hboot,CI] = Concordance(VecX,VecY,XLabel,YLabel,1,sig);

elseif strcmp(crObj(1).FigureOption,'save')

  [rC,biasFactorC,hboot,CI,Correlation(zz,kk).figure] = Concordance(VecX,VecY,XLabel,YLabel,1,sig);


  if lbIdx>1

  Correlation(zz,kk).figLabel = [XLabel '_' YLabel '_' num2str(curObj(1).StatLabels{zz})];

  else

  Correlation(zz,kk).figLabel = [XLabel '_' YLabel];

  end

elseif strcmp(crObj(1).FigureOption,'disable')

  [rC,biasFactorC,hboot,CI] = Concordance(VecX,VecY,XLabel,YLabel,0,sig);


end

% Developer:
% svds is assigned to caller (qmrstat.Concordance) workspace by
% the Concordance function.
% Other fields are filled out here below.


if obj.Export2Py

  svds.Tag.Class = 'Bivariate::Concordance';
  svds.Required.xData = VecX';
  svds.Required.yData = VecY';
  svds.Required.rhoConcordance = rC;
  svds.Required.xLabel = XLabel';
  svds.Required.yLabel = YLabel';

  svds.Optional.biasFactor = biasFactorC;
  svds.Optional.CI = CI';
  svds.Optional.CILevel = 1 - sig;
  svds.Optional.h = hboot;

  Correlation(zz,kk).SVDS = svds;

end


Correlation(zz,kk).r = rC;
Correlation(zz,kk).bias = biasFactorC;
Correlation(zz,kk).hboot = hboot;
Correlation(zz,kk).CI = CI;

end
end

end
