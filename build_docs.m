function build_docs
    % BUILD_DOCS  Genera la documentación HTML e index.html
    % Solo recompila archivos modificados.
    %
    % Estructura:
    %   docs_src/h_*.m   (publish)
    %   docs_src/h_*.mlx (export)
    %   docs/            (HTML de salida)
    %
    % Los HTML NO tendrán el prefijo "h_".

    repoRoot  = pwd;
    docSrcDir = fullfile(repoRoot, 'docs_src');
    outDir    = fullfile(repoRoot, 'docs');

    if ~exist(docSrcDir, 'dir')
        error('La carpeta docs_src no existe en: %s', docSrcDir);
    end
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    %% 1) Archivos .m con prefijo h_*
    mFiles = dir(fullfile(docSrcDir, 'h_*.m'));

    if ~isempty(mFiles)
        opts = struct();
        opts.format    = 'html';
        opts.outputDir = outDir;

        for k = 1:numel(mFiles)
            srcFile = fullfile(docSrcDir, mFiles(k).name);

            % Nombre base sin prefijo h_
            [~, base] = fileparts(mFiles(k).name);
            cleanName = remove_prefix_h(base);
            outFile   = fullfile(outDir, [cleanName '.html']);

            if needs_rebuild(srcFile, outFile)
                fprintf('Publicando (M) %s -> %s\n', srcFile, outFile);
                publish(srcFile, opts);

                % publish crea base.html; lo renombramos si hace falta
                generated = fullfile(outDir, [base '.html']);
                if exist(generated, 'file') && ~strcmp(generated, outFile)
                    movefile(generated, outFile, 'f');
                end
            else
                fprintf('Sin cambios (M) %s\n', srcFile);
            end
        end
    end

    %% 2) Archivos .mlx con prefijo h_*
    mlxFiles = dir(fullfile(docSrcDir, 'h_*.mlx'));

    if ~isempty(mlxFiles)
        if exist('export', 'file') ~= 2
            warning('No se encontró la función export(). Se omiten los .mlx.');
        else
            for k = 1:numel(mlxFiles)
                srcFile = fullfile(docSrcDir, mlxFiles(k).name);

                [~, base] = fileparts(mlxFiles(k).name);
                cleanName = remove_prefix_h(base);
                outFile   = fullfile(outDir, [cleanName '.html']);

                if needs_rebuild(srcFile, outFile)
                    fprintf('Exportando (MLX) %s -> %s\n', srcFile, outFile);
                    export(srcFile, outFile, 'Format', 'html', 'Run', true);
                else
                    fprintf('Sin cambios (MLX) %s\n', srcFile);
                end
            end
        end
    end

    %% 3) Crear/actualizar índice
    create_index_html(outDir);

    fprintf('\nDocumentación actualizada en: %s\n', outDir);
end

function cleanName = remove_prefix_h(base)
    % Quita el prefijo h_ si existe
    if strncmp(base, 'h_', 2)
        if length(base) > 2
            cleanName = base(3:end);
        else
            cleanName = '';
        end
    else
        cleanName = base;
    end
end

function tf = needs_rebuild(srcFile, outFile)
    % ¿Hace falta recompilar?
    if ~exist(outFile, 'file')
        tf = true;
        return;
    end

    srcInfo = dir(srcFile);
    outInfo = dir(outFile);

    tf = srcInfo.datenum > outInfo.datenum;
end

function create_index_html(outDir)
    htmlFiles = dir(fullfile(outDir, '*.html'));

    % Quitar el index.html
    names = {htmlFiles.name};
    isIndex = strcmpi(names, 'index.html');
    htmlFiles(isIndex) = [];

    indexFile = fullfile(outDir, 'index.html');
    fid = fopen(indexFile, 'w');
    if fid == -1
        error('No se pudo crear index.html en %s', outDir);
    end
    cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

    % Cabecera HTML
    fprintf(fid, '<!DOCTYPE html>\n');
    fprintf(fid, '<html lang="es">\n');
    fprintf(fid, '<head>\n');
    fprintf(fid, '  <meta charset="utf-8">\n');
    fprintf(fid, '  <title>SimurTools – Documentación</title>\n');
    fprintf(fid, '  <style>\n');
    fprintf(fid, '    body { font-family: Arial, sans-serif; max-width: 900px; margin: 2rem auto; line-height: 1.6; }\n');
    fprintf(fid, '    h1 { border-bottom: 1px solid #ccc; padding-bottom: .5rem; }\n');
    fprintf(fid, '    ul { list-style: none; padding-left: 0; }\n');
    fprintf(fid, '    li { margin: .3rem 0; }\n');
    fprintf(fid, '    a { text-decoration: none; color: #0072BD; }\n');
    fprintf(fid, '    a:hover { text-decoration: underline; }\n');
    fprintf(fid, '  </style>\n');
    fprintf(fid, '</head>\n');
    fprintf(fid, '<body>\n');
    fprintf(fid, '  <h1>SimurTools – Documentación</h1>\n');
    fprintf(fid, '  <p>Selecciona una página de ayuda:</p>\n');
    fprintf(fid, '  <ul>\n');

    for k = 1:numel(htmlFiles)
        fname = htmlFiles(k).name;
        [~, base] = fileparts(fname);

        % Nombre visible sin prefijo h_ y con guiones bajos como espacios
        niceName = remove_prefix_h(base);
        niceName = strrep(niceName, '_', ' ');

        fprintf(fid, '    <li><a href="%s">%s</a></li>\n', fname, niceName);
    end

    fprintf(fid, '  </ul>\n');
    fprintf(fid, '  <p style="margin-top:2rem;font-size:0.9em;color:#666;">Generado autom&aacute;ticamente por build_docs.m</p>\n');
    fprintf(fid, '</body>\n');
    fprintf(fid, '</html>\n');
end