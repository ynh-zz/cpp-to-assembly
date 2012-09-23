if (! this.sh_languages) {
  this.sh_languages = {};
}
sh_languages['asm'] = [
  [
    [
      /\b(?:external|open|include|[A-Z][\w']*(?=\.))\b/g,
      'sh_preproc',
      -1
    ],
    [
      /\t\t(?:[^ .%$-]*)/g,
      'sh_function',
      -1
    ],
    [
      /(?:[%][^\),]*)/g,
      'sh_todo',
      -1
    ],
    [
        /(?:[0-9A-F]+)\b/gi,
      'sh_comment',
      -1
    ],
    [
        /(?:[$]?[-]?[0-9]+)\b/g,
      'sh_number',
      -1
    ],
    
    [
      /"/g,
      'sh_string',
      1
    ],
    
    
   [
      /(?:[$]?[\.]?[^ \t\:]*:)\b/g,
      'sh_keyword',
      -1
    ],
       
    [
      /(?:[$]?[\.][^ \t\:]*[:]?)/g,
      'sh_type',
      -1
    ],
    [
      /\(\*/g,
      'sh_comment',
      2
    ],
    
   
    [
      /\{|\}/g,
      'sh_cbracket',
      -1
    ]
  ],
  [
    [
      /$/g,
      null,
      -2
    ],
    [
      /\\(?:\\|")/g,
      null,
      -1
    ],
    [
      /"/g,
      'sh_string',
      -2
    ]
  ],
  [
    [
      /\*\)/g,
      'sh_comment',
      -2
    ],
    [
      /\(\*/g,
      'sh_comment',
      2
    ]
  ]
];
