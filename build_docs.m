function build_docs
    % Carpeta con las ayudas fuente
    docSrcDir = fullfile(pwd, "docs_src");
    % Carpeta de salida (la que luego subes a la web / GitHub Pages)
    outDir    = fullfile(pwd, "docs");

    if ~exist(outDir, "dir")
        mkdir(outDir);
    end

    % --- 1) Documentos .m (publish clásico)
    mFiles = dir(fullfile(docSrcDir, "h_*.m"));

    opts = struct();
    opts.format    = "html";
    opts.outputDir = outDir;

    for k = 1:numel(mFiles)
        inFile = fullfile(docSrcDir, mFiles(k).name);
        fprintf("Publicando (M) %s...\n", inFile);
        publish(inFile, opts);
    end

    % --- 2) Documentos .mlx (Live Scripts -> HTML con export)
    mlxFiles = dir(fullfile(docSrcDir, "h_*.mlx"));

    for k = 1:numel(mlxFiles)
        inFile = fullfile(docSrcDir, mlxFiles(k).name);
        [~, name] = fileparts(mlxFiles(k).name);
        outFile = fullfile(outDir, name + ".html");

        fprintf("Exportando (MLX) %s -> %s\n", inFile, outFile);
        export(inFile, outFile, Format="html", Run=true);
    end
end