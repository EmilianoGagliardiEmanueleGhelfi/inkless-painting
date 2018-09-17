function out = apply_to_rows(fun, mat)
    applyToGivenRow = @(func, matrix) @(row) func(matrix(row, :));
    newApplyToRows = @(func, matrix) arrayfun(applyToGivenRow(func, matrix), 1:size(matrix,1), 'UniformOutput', false)';
    takeAll = @(x) reshape([x{:}], size(x{1},2), size(x,1))';
    out = takeAll(newApplyToRows(fun, mat));
end

