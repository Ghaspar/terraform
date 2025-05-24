## 
# Exemplo de uso do Terraform com `local_file`

Este projeto demonstra o uso do provedor `local` do Terraform para criar e ler arquivos locais no sistema de arquivos.

---

## 📁 Estrutura do projeto

```bash
.
├── local.tf         # Código principal com recursos e variáveis
└── terraform.tfvars # Valores atribuídos à variável
```

---

## 🔧 O que este projeto faz?

1. **Cria um arquivo local** chamado `foo.bar` com o conteúdo fornecido pela variável `content`.
2. **Lê esse arquivo** com o `data source` `local_file`.
3. Expõe três outputs:
   - O conteúdo lido pelo `data source`
   - O ID do arquivo criado
   - O conteúdo do recurso `local_file`

---

## 📦 Requisitos

- Terraform instalado (`terraform -v`)
- Um sistema de arquivos onde o Terraform tenha permissão de leitura e escrita

---

## 📁 Conteúdo do `terraform.tfvars` (exemplo)

```hcl
content = "Olá, este é um teste com Terraform!"
```

---

## 🚀 Comandos para rodar o projeto

### 1. Inicializar o projeto

```bash
terraform init
```

### 2. Verificar o plano de execução

```bash
terraform plan
```

### 3. Aplicar as mudanças

```bash
terraform apply
```

### 4. Ver os outputs

Após o `apply`, os seguintes outputs serão exibidos:

- `data-source`: conteúdo do arquivo lido
- `id_archive`: ID do arquivo criado
- `content`: conteúdo do arquivo criado

---

## 🧹 Destruir os recursos

```bash
terraform destroy
```

---

## 📝 Observações

- Este projeto utiliza o provedor `local`, que é útil para testes e manipulação de arquivos simples.
- Evite usar `local_file` em ambientes de produção, pois não é adequado para gerenciar infraestrutura remota.

---

## 📚 Referência

- [Documentação do local_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file)
- [Documentação do data source local_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file)
