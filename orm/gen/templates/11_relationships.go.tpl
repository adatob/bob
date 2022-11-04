{{$table := .Table}}
{{$tAlias := .Aliases.Table $table.Name -}}

{{range $rel := $table.Relationships -}}
{{- $ftable := $.Aliases.Table $rel.Foreign -}}
{{- $relAlias := $tAlias.Relationship $rel.Name -}}
{{- if not $rel.IsToMany -}}
  func (o *{{$tAlias.UpSingular}}) Insert{{$relAlias}}(ctx context.Context, exec bob.Executor,{{relDependencies $.Aliases $rel}} related *Optional{{$ftable.UpSingular}}) error {
    {{if $rel.InsertEarly -}}
      rel, err := {{$ftable.UpPlural}}Table.Insert(ctx, exec, related)
      if err != nil {
          return fmt.Errorf("inserting related objects: %w", err)
      }
			o.R.{{$relAlias}} = rel
    {{else -}}
      rel := related
    {{end}}

    {{$create := createDeps $.Aliases $rel false}}
    {{$create}}

    {{setDeps $.Importer $.Tables $.Aliases $rel false false true}}

    {{insertDeps $.Aliases $rel false}}

    {{if not $rel.InsertEarly -}}
      inserted, err := {{$ftable.UpPlural}}Table.Insert(ctx, exec, related)
      if err != nil {
          return fmt.Errorf("inserting related objects: %w", err)
      }
			o.R.{{$relAlias}} = inserted
    {{end}}

    return nil
  }

  func (o *{{$tAlias.UpSingular}}) Attach{{$relAlias}}(ctx context.Context, exec bob.Executor,{{relDependencies $.Aliases $rel}} rel *{{$ftable.UpSingular}}) error {
    var err error

    {{$create := createDeps $.Aliases $rel false}}
    {{$create}}

    {{setDeps $.Importer $.Tables $.Aliases $rel false false false}}

    {{insertDeps $.Aliases $rel false}}

    _, err = rel.Update(ctx, exec, nil)
    if err != nil {
        return fmt.Errorf("inserting related objects: %w", err)
    }
    o.R.{{$relAlias}} = rel

    return nil
  }

  {{if or $rel.ByJoinTable $rel.IsRemovable -}}
  func (o *{{$tAlias.UpSingular}}) Remove{{$relAlias}}(ctx context.Context, exec bob.Executor, related ...*{{$ftable.UpSingular}}) {
  }

  {{end -}}
{{else -}}
  func (o *{{$tAlias.UpSingular}}) Insert{{$relAlias}}(ctx context.Context, exec bob.Executor,{{relDependencies $.Aliases $rel}} related ...*Optional{{$ftable.UpSingular}}) error {
    var err error

    {{if $rel.InsertEarly -}}
      rels, err := {{$ftable.UpPlural}}Table.InsertMany(ctx, exec, related...)
      if err != nil {
          return fmt.Errorf("inserting related objects: %w", err)
      }
			o.R.{{$relAlias}} = append(o.R.{{$relAlias}}, rels...)
    {{else -}}
      rels := related
    {{end}}

    {{$create := createDeps $.Aliases $rel true}}
    {{$create}}

    for {{if $create}}i{{else}}_{{end}}, rel := range rels {
      {{setDeps $.Importer $.Tables $.Aliases $rel false true true}}
    }

    {{insertDeps $.Aliases $rel true}}

    {{if not $rel.InsertEarly -}}
      inserted, err := {{$ftable.UpPlural}}Table.InsertMany(ctx, exec, related...)
      if err != nil {
          return fmt.Errorf("inserting related objects: %w", err)
      }
			o.R.{{$relAlias}} = append(o.R.{{$relAlias}}, inserted...)
    {{end}}

    return nil
  }

  func (o *{{$tAlias.UpSingular}}) Attach{{$relAlias}}(ctx context.Context, exec bob.Executor,{{relDependencies $.Aliases $rel}} related ...*{{$ftable.UpSingular}}) error {
    var err error

    {{$create := createDeps $.Aliases $rel true}}
    {{$create}}

    for {{if $create}}i{{else}}_{{end}}, rel := range related {
      {{setDeps $.Importer $.Tables $.Aliases $rel false true false}}
    }

    {{insertDeps $.Aliases $rel true}}

    {{$relatedVals := relatedUpdateValues $.Importer $.Tables $.Aliases $rel true}}
    {{with $relatedVals}}
    _, err = {{$ftable.UpPlural}}Table.UpdateMany(
      ctx, exec, &Optional{{$ftable.UpSingular}}{
        {{.}}
      }, related...,
    )
    if err != nil {
        return fmt.Errorf("inserting related objects: %w", err)
    }
    {{end}}

		o.R.{{$relAlias}} = append(o.R.{{$relAlias}}, related...)
    return nil
  }

  {{if  $rel.IsRemovable -}}
  func (o *{{$tAlias.UpSingular}}) Detach{{$relAlias}}(ctx context.Context, exec bob.Executor, related ...*{{$ftable.UpSingular}}) {
  }
  {{end -}}
{{end -}}

{{end -}}
