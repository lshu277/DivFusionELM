function [pivotOrder, triangularFactor] = column_pivot_order(H)
%COLUMN_PIVOT_ORDER Obtain column pivot ordering from QR factorization.

try
    [~, triangularFactor, pivotOrder] = qr(H, 0, 'vector');
    pivotOrder = pivotOrder(:)';
catch
    [~, triangularFactor, permutationMatrix] = qr(H, 0);
    [~, pivotOrder] = max(abs(permutationMatrix), [], 1);
    pivotOrder = pivotOrder(:)';
end

numColumns = size(H, 2);
if numel(unique(pivotOrder)) ~= numel(pivotOrder) || any(sort(pivotOrder) ~= 1:numColumns)
    pivotOrder = 1:numColumns;
end

end
