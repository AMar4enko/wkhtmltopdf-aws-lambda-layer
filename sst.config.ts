/// <reference path="./.sst/platform/config.d.ts" />
import { lambda } from '@pulumi/aws'
import { asset } from '@pulumi/pulumi'
import path from 'path'
export default $config({
  app(input) {
    return {
      name: 'wkhtmltopdf',
      removal: input?.stage === 'production' ? 'retain' : 'remove',
      protect: ['production'].includes(input?.stage),
      home: 'aws',
    }
  },
  async run() {
    
    new lambda.LayerVersion(`${$app.name}-${$app.stage}-layer`, {
      layerName: `wkhtmltopdf`,
      description: 'WKHTMLTOPDF',
      compatibleArchitectures: ['x86_64'],
      code: new asset.FileArchive(path.join($cli.paths.root, 'layer.zip'))
    })
  }
})
