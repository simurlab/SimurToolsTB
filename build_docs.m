function build_docs
    % BUILD_DOCS  Genera la documentación HTML y un índice index.html
    % Solo recompila los archivos cuya fuente haya cambiado.
    %
    % Estructura asumida:
    %   repo/
    %     docs_src/   -> doc_*.m y doc_*.mlx (fuentes de ayuda)
    %     docs/       -> .html generados + index.html
    %
    % Llamar desde la raíz del repo.

    repoRoot  = pwd;
    docSrcDir = fullfile(repoRoot, "docs_src");
    outDir    = fullfile(repoRoot, "docs");

    if ~exist(docSrcDir, "dir")
        error("La carpeta docs_src no existe en: %s", docSrcDir);
    end

    if ~exist(outDir, "dir")
        mkdir(outDir);
    end

    %% 1) Publicar documentos .m con publish (solo si han cambiado)
    mFiles = dir(fullfile(docSrcDir, "h_*.m"));

    if ~isempty(mFiles)
        opts = struct();
        opts.format    = "html";
        opts.outputDir = outDir;

        for k = 1:numel(mFiles)
            srcFile = fullfile(docSrcDir, mFiles(k).name);
            [~, base] = fileparts(mFiles(k).name);
            outFile = fullfile(outDir, base + ".html");

            if needs_rebuild(srcFile, outFile)
                fprintf("Publicando (M) %s -> %s\n", srcFile, outFile);
                publish(srcFile, opts);
            else
                fprintf("Sin cambios (M) %s, no se recompila.\n", srcFile);
            end
        end
    end

    %% 2) Exportar documentos .mlx con export (solo si han cambiado)
    mlxFiles = dir(fullfile(docSrcDir, "h_*.mlx"));

    if ~isempty(mlxFiles)
        if exist("export", "file") ~= 2
            warning("No se encontró la función EXPORT. Se omiten los .mlx.");
        else
            for k = 1:numel(mlxFiles)
                srcFile = fullfile(docSrcDir, mlxFiles(k).name);
                [~, base] = fileparts(mlxFiles(k).name);
                outFile = fullfile(outDir, base + ".html");

                if needs_rebuild(srcFile, outFile)
                    fprintf("Exportando (MLX) %s -> %s\n", srcFile, outFile);
                    export(srcFile, outFile, Format="html", Run=true);
                else
                    fprintf("Sin cambios (MLX) %s, no se recompila.\n", srcFile);
                end
            end
        end
    end

    %% 3) Crear/actualizar siempre el índice HTML
    create_index_html(outDir);

    fprintf("\nDocumentación actualizada en: %s\n", outDir);
end

function tf = needs_rebuild(srcFile, outFile)
    % Devuelve true si hay que recompilar:
    % - porque no existe el HTML
    % - o porque la fecha de modificación del .m/.mlx es más reciente

    if ~exist(outFile, "file")
        tf = true;
        return;
    end

    srcInfo = dir(srcFile);
    outInfo = dir(outFile);

    % datenum / datetime: compara fechas
    tf = srcInfo.datenum > outInfo.datenum;
end

function create_index_html(outDir)
    % Crea docs/index.html listando todos los .html en outDir
    htmlFiles = dir(fullfile(outDir, "*.html"));

    % Excluir el propio index.html si ya existe
    names = {htmlFiles.name};
    isIndex = strcmpi(names, "index.html");
    htmlFiles(isIndex) = [];

    indexFile = fullfile(outDir, "index.html");
    fid = fopen(indexFile, "w");
    if fid == -1
        error("No se pudo crear index.html en %s", outDir);
    end

    cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

    fprintf(fid, "<!DOCTYPE html>\n");
    fprintf(fid, "<html lang=""es"">\n");
    fprintf(fid, "<head>\n");
    fprintf(fid, "  <meta charset=""utf-8"">\n");
    fprintf(fid, "  <title>SimurTools – Documentación</title>\n");
    fprintf(fid, "  <style>\n");
    fprintf(fid, "    body { font-family: Arial, sans-serif; max-width: 900px; margin: 2rem auto; line-height: 1.6; }\n");
    fprintf(fid, "    h1 { border-bottom: 1px solid #ccc; padding-bottom: .5rem; }\n");
    fprintf(fid, "    ul { list-style: none; padding-left: 0; }\n");
    fprintf(fid, "    li { margin: .3rem 0; }\n");
    fprintf(fid, "    a { text-decoration: none; color: #0072BD; }\n");
    fprintf(fid, "    a:hover { text-decoration: underline; }\n");
    fprintf(fid, "  </style>\n");
    fprintf(fid, "</head>\n");
    fprintf(fid, "<body>\n");
    fprintf(fid, "  <h1>SimurTools – Documentación</h1>\n");
    fprintf(fid, "  <p>Selecciona una página de ayuda:</p>\n");
    fprintf(fid, "  <ul>\n");

    for k = 1:numel(htmlFiles)
        fname = htmlFiles(k).name;
        [~, base] = fileparts(fname);

        % Título amigable: quita prefijo "doc_" si lo tiene y cambia guiones/bajos por espacios
        niceName = base;
        if startsWith(niceName, "doc_")
            niceName = extractAfter(niceName, "doc_");
        end
        niceName = strrep(niceName, "_", " ");

        fprintf(fid, '    <li><a href="%s">%s</a></li>\n', fname, niceName);
    end

    fprintf(fid, "  </ul>\n");
    fprintf(fid, "  <p style=""margin-top:2rem;font-size:0.9em;color:#666;"">Generado automáticamente por build_docs.m</p>\n");
    fprintf(fid, "</body>\n");
    fprintf(fid, "</html>\n");
end