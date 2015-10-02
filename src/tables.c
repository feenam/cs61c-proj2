
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "utils.h"
#include "tables.h"

const int SYMTBL_NON_UNIQUE = 0;
const int SYMTBL_UNIQUE_NAME = 1;

#define INITIAL_SIZE 5
#define SCALING_FACTOR 2

/*******************************
 * Helper Functions
 *******************************/

void allocation_failed() {
    write_to_log("Error: allocation failed\n");
    exit(1);
}

void addr_alignment_incorrect() {
    write_to_log("Error: address is not a multiple of 4.\n");
}

void name_already_exists(const char* name) {
    write_to_log("Error: name '%s' already exists in table.\n", name);
}

void write_symbol(FILE* output, uint32_t addr, const char* name) {
    fprintf(output, "%u\t%s\n", addr, name);
}

/*******************************
 * Symbol Table Functions
 *******************************/

/* Creates a new SymbolTable containing 0 elements and returns a pointer to that
   table. Multiple SymbolTables may exist at the same time. 
   If memory allocation fails, you should call allocation_failed(). 
   Mode will be either SYMTBL_NON_UNIQUE or SYMTBL_UNIQUE_NAME. You will need
   to store this value for use during add_to_table().
 */
SymbolTable* create_table(int mode) {
    /* Allocate the memory for the struct */
    SymbolTable* newST = malloc(sizeof(SymbolTable));

    /* Check return value to make sure we got memory */
    if(!newST) allocation_failed();

    /* Store mode and initialize data*/
    newST->mode = mode;
    newST->len = 0;
    newST->cap = INITIAL_SIZE;
    newST->tbl = malloc(INITIAL_SIZE * sizeof(Symbol));
    
    /* Check our return value to make sure we got memory */
    if(!newST->tbl) {
      free(newST);
      allocation_failed();
    }

    /* Return ST pointer */
    return newST;
}

/* Frees the given SymbolTable and all associated memory. */
void free_table(SymbolTable* table) {
    int loc = 0;
    while (loc < table->len){
      Symbol* sym = &(table->tbl[loc]);
      // free(sym->name);
      // free(sym->addr);
      free(sym);
      loc++;
    }
    free(table->tbl);
    free(table);
}

/* A suggested helper function for copying the contents of a string. */
static char* create_copy_of_str(const char* str) {
    size_t len = strlen(str) + 1;
    char *buf = (char *) malloc(len);
    if (!buf) {
       allocation_failed();
    }
    strncpy(buf, str, len); 
    return buf;
}

/* Adds a new symbol and its address to the SymbolTable pointed to by TABLE. 
   ADDR is given as the byte offset from the first instruction. The SymbolTable
   must be able to resize itself as more elements are added. 

   Note that NAME may point to a temporary array, so it is not safe to simply
   store the NAME pointer. You must store a copy of the given string.

   If ADDR is not word-aligned, you should call addr_alignment_incorrect() and
   return -1. If the table's mode is SYMTBL_UNIQUE_NAME and NAME already exists 
   in the table, you should call name_already_exists() and return -1. If memory
   allocation fails, you should call allocation_failed(). 

   Otherwise, you should store the symbol name and address and return 0.
 */
int add_to_table(SymbolTable* table, const char* name, uint32_t addr) {
    
  /* check that addr is word-aligned */
  if (addr % 4) {
    addr_alignment_incorrect();
    return -1;
  }
  
  /* check that name exists in the table if mode is UNIQUE */
  if ((table->mode) && (get_addr_for_symbol(table, name) != -1)) {
    name_already_exists(name);
    return -1;
  }
  
  /* Resize the tbl array if necessary */
  if (table->len == table->cap){
    table->tbl = (Symbol*) realloc(table->tbl, sizeof(*(table->tbl)) * SCALING_FACTOR);
    if (!table->tbl) allocation_failed();
    table->cap = table->cap * SCALING_FACTOR;
  }

  /* Create a copy of the name string */
  char* name_copy = create_copy_of_str(name);

  /* Add the new name and addr*/
  Symbol* new_symbol =  malloc(sizeof(Symbol));
  if (!new_symbol) allocation_failed();
  new_symbol->name = name_copy;
  new_symbol->addr = addr;
  table->tbl[(table->len)] = *new_symbol;
  
  /* Update tbl length and return 0*/
  table->len++;
  return 0;
}

/* Returns the address (byte offset) of the given symbol. If a symbol with name
   NAME is not present in TABLE, return -1.
 */
int64_t get_addr_for_symbol(SymbolTable* table, const char* name) {
    
    /* index through the tbl array and try to find a copy of the name */
    int loc = 0;
    while (loc < table->len){
      Symbol* sym = &(table->tbl[loc]);
      if (!(strcmp(sym->name, name))) return sym->addr;
      loc++;
    }

    /* if not present return -1 */
    return -1;
}

/* Writes the SymbolTable TABLE to OUTPUT. You should use write_symbol() to
   perform the write. Do not print any additional whitespace or characters.
 */
void write_table(SymbolTable* table, FILE* output) {

    /* index through the tbl array and write each to Output */
    int loc = 0;
    while (loc < table->len){
      Symbol* sym = &(table->tbl[loc]);
      write_symbol(output, sym->addr, sym->name);
      loc++;
      // NEED TO REMOVE WHITESPACE/CHARACTERS?                                  DELETE WHEN DONE
    }
}
